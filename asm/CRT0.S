        .text

        .equ __FastInterrupts, 1
@       .equ __SingleInterrupts, 1
@       .equ __MultipleInterrupts, 1

	.global     _start
	
        .align
	.arm

@---------------------------------------------------------------------------------
_start:
@---------------------------------------------------------------------------------
	b	rom_header_end

	.fill   156,1,0			@ Nintendo Logo Character Data (8000004h)
	.fill	16,1,0			@ Game Title
	.byte   0x30,0x31		@ Maker Code (80000B0h)
	.byte   0x96			@ Fixed Value (80000B2h)
	.byte   0x00			@ Main Unit Code (80000B3h)
	.byte   0x00			@ Device Type (80000B4h)
	.fill	7,1,0			@ unused
	.byte	0x00			@ Software Version No (80000BCh)
	.byte	0xf0			@ Complement Check (80000BDh)
	.byte	0x00,0x00    		@ Checksum (80000BEh)

        .align
        .arm

@---------------------------------------------------------------------------------
rom_header_end:
@---------------------------------------------------------------------------------
	b	    start_vector	        @ This branch must be here for proper
						@ positioning of the following header.
	.global     start_vector
	.align
        .arm

@---------------------------------------------------------------------------------
start_vector:
@---------------------------------------------------------------------------------
	mov	r0, #0x12			@ Switch to IRQ Mode
	msr	cpsr, r0
	ldr	sp, =__sp_irq			@ Set IRQ stack
	mov	r0, #0x1f			@ Switch to System Mode
	msr	cpsr, r0
	ldr	sp, =__sp_usr			@ Set user stack

@---------------------------------------------------------------------------------
@ Enter Thumb mode
@---------------------------------------------------------------------------------
	add	r0, pc, #1
	bx	r0

	.thumb

@---------------------------------------------------------------------------------
@ Interrupt Support
@---------------------------------------------------------------------------------
        ldr     r1, =__intr_vector_buf  @ Set Interrupt Address
        ldr     r0, =intr_main
        str     r0, [r1]

@---------------------------------------------------------------------------------
DoEWRAMClear:					@ Clear External WRAM to 0x00
@---------------------------------------------------------------------------------
	mov	r1, #0x40
	lsl	r1, #12				@ r1 = 0x40000
	lsl	r0, r1, #7			@ r0 = 0x2000000
	bl	ClearMem

@---------------------------------------------------------------------------------
@ Copy initialized data (data section) from LMA to VMA (ROM to RAM)
@---------------------------------------------------------------------------------
	ldr	r1, =__data_lma
	ldr	r2, =__data_start
	ldr	r4, =__data_end
	bl	CopyMemChk

@---------------------------------------------------------------------------------
@ Copy internal work ram (iwram section) from LMA to VMA (ROM to RAM)
@---------------------------------------------------------------------------------
	ldr	r1,= __iwram_lma
	ldr	r2,= __iwram_start
	ldr	r4,= __iwram_end
	bl	CopyMemChk

@---------------------------------------------------------------------------------
@ Copy internal work ram overlay 0 (iwram0 section) from LMA to VMA (ROM to RAM)
@---------------------------------------------------------------------------------
	ldr	r2,= __load_stop_iwram0
	ldr	r1,= __load_start_iwram0
	sub	r3, r2, r1			@ Is there any data to copy?
	beq	CIW0Skip			@ no

	ldr	r2,= __iwram_overlay_start
	bl	CopyMem

@---------------------------------------------------------------------------------
CIW0Skip:
@---------------------------------------------------------------------------------
@ Copy external work ram (ewram section) from LMA to VMA (ROM to RAM)
@---------------------------------------------------------------------------------
	ldr	r1, =__ewram_lma
	ldr	r2, =__ewram_start
	ldr	r4, =__ewram_end
	bl	CopyMemChk

@---------------------------------------------------------------------------------
CEW0Skip:
@---------------------------------------------------------------------------------
@ Jump to user code
@---------------------------------------------------------------------------------
	ldr	r3, =AgbMain
	bl	_blx_r3_stub

@---------------------------------------------------------------------------------
@ Clear memory to 0x00 if length != 0
@---------------------------------------------------------------------------------
@ r0 = Start Address
@ r1 = Length
@---------------------------------------------------------------------------------
ClearMem:
@---------------------------------------------------------------------------------
	mov	r2,#3				@ These	commands are used in cases where
	add	r1,r2				@ the length is	not a multiple of 4,
	bic	r1,r2				@ even though it should be.

	beq	ClearMX				@ Length is zero so exit

	mov	r2,#0

@---------------------------------------------------------------------------------
ClrLoop:
@---------------------------------------------------------------------------------
	stmia	r0!, {r2}
	sub	r1,#4
	bne	ClrLoop

@---------------------------------------------------------------------------------
ClearMX:
@---------------------------------------------------------------------------------
	bx	lr

@---------------------------------------------------------------------------------
_blx_r3_stub:
@---------------------------------------------------------------------------------
	bx	r3

@---------------------------------------------------------------------------------
@ Copy memory if length	!= 0
@---------------------------------------------------------------------------------
@ r1 = Source Address
@ r2 = Dest Address
@ r4 = Dest Address + Length
@---------------------------------------------------------------------------------
CopyMemChk:
@---------------------------------------------------------------------------------
	sub	r3, r4, r2			@ Is there any data to copy?

@---------------------------------------------------------------------------------
@ Copy memory
@---------------------------------------------------------------------------------
@ r1 = Source Address
@ r2 = Dest Address
@ r3 = Length
@---------------------------------------------------------------------------------
CopyMem:
@---------------------------------------------------------------------------------
	mov	r0, #3				@ These commands are used in cases where
	add	r3, r0				@ the length is not a multiple	of 4,
	bic	r3, r0				@ even	though it should be.
	beq	CIDExit				@ Length is zero so exit

@---------------------------------------------------------------------------------
CIDLoop:
@---------------------------------------------------------------------------------
	ldmia	r1!, {r0}
	stmia	r2!, {r0}
	sub	r3, #4
	bne	CIDLoop

@---------------------------------------------------------------------------------
CIDExit:
@---------------------------------------------------------------------------------
        bx	lr

        .align
        .pool

@---------------------------------------------------------------------------------
@ Interrupt Support
@---------------------------------------------------------------------------------
        .section .iwram, "ax" ,%progbits
        .extern IntrTable
        .extern InterruptProcess
        .global intr_main

        .arm

        .ifdef __FastInterrupts                         @ Fast interrupt
                intr_main:
                        ldr     r0,=InterruptProcess
                        bx      r0
        .endif
        .ifdef __SingleInterrupts                        @ Single interrupts support
                intr_main:
                        mov     r3, #0x4000000           @ REG_BASE
                        ldr     r2, [r3,#0x200]!         @ Read REG_IE
                        and     r1, r2, r2, lsr #16      @ r1 = IE & IF
                        ldr     r2, =IntrTable
                        ands    r0, r1, #1               @ V-Blank Interrupt
                        bne     jump_intr
                        add     r2, r2, #4
                        ands    r0, r1, #2               @ H-Blank Interrupt
                        bne     jump_intr
                        add     r2, r2, #4
                        ands    r0, r1, #4               @ V Counter Interrupt
                        bne     jump_intr
                        add     r2, r2, #4
                        ands    r0, r1, #8               @ Timer 0 Interrupt
                        bne     jump_intr
                        add     r2, r2, #4
                        ands    r0, r1, #0x10            @ Timer 1 Interrupt
                        bne     jump_intr
                        add     r2, r2, #4
                        ands    r0, r1, #0x20            @ Timer 2 Interrupt
                        bne     jump_intr
                        add     r2, r2, #4
                        ands    r0, r1, #0x40            @ Timer 3 Interrupt
                        bne     jump_intr
                        add     r2, r2, #4
                        ands    r0, r1, #0x80            @ Serial Communication Interrupt
                        bne     jump_intr
                        add     r2, r2, #4
                        ands    r0, r1, #0x100           @ DMA0 Interrupt
                        bne     jump_intr
                        add     r2, r2, #4
                        ands    r0, r1, #0x200           @ DMA1 Interrupt
                        bne     jump_intr
                        add     r2, r2, #4
                        ands    r0, r1, #0x400           @ DMA2 Interrupt
                        bne     jump_intr
                        add     r2, r2, #4
                        ands    r0, r1, #0x800           @ DMA3 Interrupt
                        bne     jump_intr
                        add     r2, r2, #4
                        ands    r0, r1, #0x1000          @ Key Interrupt
                        bne     jump_intr
                        add     r2, r2, #4
                        ands    r0, r1, #0x2000          @ Cart Interrupt
                        strneb  r0, [r3, #0x84 - 0x200]  @ Stop sound if cart removed (REG_SOUNDCNT_X)
                loop:   
                        bne     loop
                jump_intr:
                        strh    r0, [r3, #2]             @ IF Clear
                        ldr     r0, [r2]                 @ Jump to user IRQ process
                        bx      r0                     
        .endif
        .ifdef __MultipleInterrupts                      @ Multiple interrupts support
                intr_main:       
                        mov     r2, #0x4000000           @ REG_BASE
                        ldr     r3, [r2,#0x200]!         @ r2 = IE : r3 = IF|IE
                        ldrh    r1, [r2, #0x8]           @ r1 = IME
                        mrs     r0, spsr
                        stmfd   sp!, {r0-r2,lr}          @ {spsr, IME, REG_IE, lr}  // IF|IE
                        mov     r0, #1                   
                        strh    r0, [r2, #0x8]
                        and     r1, r3, r3, lsr #16      @ r1 = IE & IF
                        ldr     r12, =IntrTable
                        ands    r0, r1, #1               @ V-blank interrupt
                        bne     jump_intr
                        add     r12,r12, #4
                        ands    r0, r1, #2               @ H-blank interrupt
                        bne     jump_intr
                        add     r12,r12, #4
                        ands    r0, r1, #4               @ V-counter interrupt
                        bne     jump_intr
                        add     r12,r12, #4
                        ands    r0, r1, #8               @ Timer 0 interrupt
                        bne     jump_intr
                        add     r12,r12, #4
                        ands    r0, r1, #0x10            @ Timer 1 interrupt
                        bne     jump_intr
                        add     r12,r12, #4
                        ands    r0, r1, #0x20            @ Timer 2 interrupt
                        bne     jump_intr
                        add     r12,r12, #4
                        ands    r0, r1, #0x40            @ Timer 3 interrupt
                        bne     jump_intr
                        add     r12,r12, #4
                        ands    r0, r1, #0x80            @ Serial Communication Interrupt
                        bne     jump_intr
                        add     r12,r12, #4
                        ands    r0, r1, #0x100           @ DMA 0 interrupt
                        bne     jump_intr
                        add     r12,r12, #4
                        ands    r0, r1, #0x200           @ DMA 1 interrupt
                        bne     jump_intr
                        add     r12,r12, #4
                        ands    r0, r1, #0x400           @ DMA 2 interrupt
                        bne     jump_intr
                        add     r12,r12, #4
                        ands    r0, r1, #0x800           @ DMA 3 interrupt
                        bne     jump_intr
                        add     r12,r12, #4
                        ands    r0, r1, #0x1000          @ Key interrupt
                        bne     jump_intr
                        add     r12,r12, #4
                        ands    r0, r1, #0x2000          @ Cart interrupt
                        strneb  r0, [r3, #0x84 - 0x200]  @ Stop sound if cart removed (REG_SOUNDCNT_X)
                loop:   
                        bne     loop
                jump_intr:
                        strh    r0, [r2, #2]             @ Clear IF
                        mrs     r3, cpsr
                        bic     r3, r3, #0xc0            @ Enable IRQ & FIQ
                        msr     cpsr, r3
                        ldr     r0, [r12]
                        stmfd   sp!, {lr}
                        adr     lr, IntrRet
                        bx      r0
                IntrRet:
                        ldmfd   sp!, {lr}
                        mrs     r3, cpsr
                        orr     r3, r3, #0x80
                        msr     cpsr, r3
                        ldmfd   sp!, {r0-r2,lr}          @ {spsr, IME, REG_IE, lr}  //IF|IE
                        strh    r1,  [r2, #0x8]          @ restore REG_IME
                        msr     spsr, r0                 @ restore spsr
                        bx      lr

                .align
                .pool

                intr_main_end:
        .endif

        .align
	.pool

	.end
