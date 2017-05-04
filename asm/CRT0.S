        .text
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
	.byte	0x00,0x00    	@ Checksum (80000BEh)

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
	mov	r0, #0x12				@ Switch to IRQ Mode
	msr	cpsr, r0
	ldr	sp, =__sp_irq			@ Set IRQ stack
	mov	r0, #0x1f				@ Switch to System Mode
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
        ldr     r1, =__intr_vector_buf          @ Set Interrupt Address
        ldr     r0, =IntrMain
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
	sub	r3, r2, r1				@ Is there any data to copy?
	beq	CIW0Skip				@ no

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
	ldr	r3, =agb_main
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
@ Interrupt Handler
@---------------------------------------------------------------------------------
	.section	.iwram,"ax",%progbits
	.extern	INTR_TABLE
	.code 32

	.global	IntrMain
@---------------------------------------------------------------------------------
IntrMain:
@---------------------------------------------------------------------------------
	mov	r3, #0x4000000			@ REG_BASE
	ldr	r2, [r3,#0x200]			@ Read	REG_IE

	ldr	r1, [r3, #0x208]		@ r1 = IME
	str	r3, [r3, #0x208]		@ disable IME
	mrs	r0, spsr
	stmfd	sp!, {r0-r1,r3,lr}	@ {spsr, IME, REG_BASE, lr_irq}

	and	r1, r2,	r2, lsr #16	@ r1 =	IE & IF

	ldrh	r2, [r3, #-8]		@\mix up with BIOS irq flags at 3007FF8h,
	orr	r2, r2, r1				@ aka mirrored at 3FFFFF8h, this is required
	strh	r2, [r3, #-8]		@/when using the (VBlank)IntrWait functions

	ldr	r2,=INTR_TABLE
	add	r3,r3,#0x200

@---------------------------------------------------------------------------------
findIRQ:
@---------------------------------------------------------------------------------
	ldr	r0, [r2, #4]			@ Interrupt mask
	cmp	r0,#0
	beq	no_handler
	ands	r0, r0, r1
	bne	jump_intr
	add	r2, r2, #8
	b	findIRQ

@---------------------------------------------------------------------------------
no_handler:
@---------------------------------------------------------------------------------
	strh	r1, [r3, #0x02]		@ IF Clear
	ldmfd	sp!, {r0-r1,r3,lr}	@ {spsr, IME, REG_BASE, lr_irq}
	str	r1, [r3, #0x208]		@ restore REG_IME
	mov	pc,lr

@---------------------------------------------------------------------------------
jump_intr:
@---------------------------------------------------------------------------------
	ldr	r2, [r2]				@ user IRQ handler address
	cmp	r2, #0
	beq	no_handler

@---------------------------------------------------------------------------------
got_handler:
@---------------------------------------------------------------------------------

	mrs	r1, cpsr
	bic	r1, r1, #0xdf			@ \__
	orr	r1, r1, #0x1f			@ /  --> Enable IRQ & FIQ. Set CPU mode to System.
	msr	cpsr,r1

	strh	r0, [r3, #0x02]		@ IF Clear
	
	push	{lr}
	adr	lr, IntrRet
	bx	r2

@---------------------------------------------------------------------------------
IntrRet:
@---------------------------------------------------------------------------------
	pop	{lr}
	mov	r3, #0x4000000			@ REG_BASE
	str	r3, [r3, #0x208]		@ disable IME

	mrs	r3, cpsr
	bic	r3, r3, #0xdf			@ \__
	orr	r3, r3, #0x92			@ /  --> Disable IRQ. Enable FIQ. Set CPU mode to IRQ.
	msr	cpsr, r3

	ldmfd   sp!, {r0-r1,r3,lr}	@ {spsr, IME, REG_BASE, lr_irq}
	str	r1, [r3, #0x208]		@ restore REG_IME
	msr	spsr, r0				@ restore spsr
	mov	pc,lr

    .align
	.pool
	.end