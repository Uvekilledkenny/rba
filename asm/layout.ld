ENTRY(_start)

MEMORY
{
    EWRAM (xrw) : ORIGIN = 0x02000000, LENGTH = 256K
    IWRAM (xrw) : ORIGIN = 0x03000000, LENGTH = 32K
    ROM   (rx)  : ORIGIN = 0x08000000, LENGTH = 32M	
}

__text_start	    =	ORIGIN(ROM);
__iwram_start	    =	ORIGIN(IWRAM);
__iwram_top	        =	ORIGIN(IWRAM) + LENGTH(IWRAM);
__intr_vector_buf   =   __iwram_top - 4;
__sp_irq	        =	__iwram_top - 0x060;
__sp_usr	        =	__sp_irq - 0x0a0;
__sp_usr_offset     =   __sp_usr - __iwram_start;

SECTIONS
{
	.text __text_start :
	{
		*(.text) 
        *(.text.*)
		*(.glue_7t) 
        *(.glue_7) 
		. = ALIGN(4);
	} > ROM = 0xFF
	__text_end = .;

	.rodata :
	{
		*(.rodata)
		*(.rodata.*)
		. = ALIGN(4);   
	} > ROM = 0xFF

	__iwram_lma = .;
	.iwram __iwram_start : AT (__iwram_lma)
	{
		*(.iwram)
		*iwram.*(.text)
		. = ALIGN(4);
	} > IWRAM = 0xFF
    __iwram_end = . ;

	.bss ALIGN(4) (NOLOAD) :
	{
		*(.bss*)
		. = ALIGN(4);
	} AT > IWRAM

	__data_lma = __iwram_lma + SIZEOF(.iwram) ;

	.data ALIGN(4) : AT (__data_lma)
	{
        __data_start = ABSOLUTE(.);
		*(.data)
		. = ALIGN(4);
	} > IWRAM = 0xFF
    __data_end  =  .;

	__iwram_overlay_lma = __data_lma + SIZEOF(.data);
	__iwram_overlay_start = . ;
	OVERLAY ALIGN(4) : NOCROSSREFS AT (__iwram_overlay_lma)
	{
		.iwram0 { *(.iwram0) . = ALIGN(4);}
		.iwram1 { *(.iwram1) . = ALIGN(4);}
		.iwram2 { *(.iwram2) . = ALIGN(4);}
		.iwram3 { *(.iwram3) . = ALIGN(4);}
		.iwram4 { *(.iwram4) . = ALIGN(4);}
		.iwram5 { *(.iwram5) . = ALIGN(4);}
		.iwram6 { *(.iwram6) . = ALIGN(4);}
		.iwram7 { *(.iwram7) . = ALIGN(4);}
		.iwram8 { *(.iwram8) . = ALIGN(4);}
		.iwram9 { *(.iwram9) . = ALIGN(4);}
	} > IWRAM = 0xFF
	__iwram_overlay_end = . ;

    __ewram_lma = __iwram_overlay_lma + (__iwram_overlay_end - __iwram_overlay_start) ;
	__ewram_start = ORIGIN(EWRAM);
	.ewram __ewram_start : AT (__ewram_lma)
	{
		*(.ewram)
		. = ALIGN(4);
		__ewram_end = ABSOLUTE(.);
	} > EWRAM = 0xFF


	__ewram_overlay_lma = __ewram_lma + SIZEOF(.ewram);
    __ewram_overlay_start = . ;
    OVERLAY ALIGN(4): NOCROSSREFS AT (__ewram_overlay_lma)
    {
        .ewram0 { *(.ewram0) . = ALIGN(4);}
        .ewram1 { *(.ewram1) . = ALIGN(4);}
        .ewram2 { *(.ewram2) . = ALIGN(4);}
        .ewram3 { *(.ewram3) . = ALIGN(4);}
        .ewram4 { *(.ewram4) . = ALIGN(4);}
        .ewram5 { *(.ewram5) . = ALIGN(4);}
        .ewram6 { *(.ewram6) . = ALIGN(4);}
        .ewram7 { *(.ewram7) . = ALIGN(4);}
        .ewram8 { *(.ewram8) . = ALIGN(4);}
        .ewram9 { *(.ewram9) . = ALIGN(4);}
    } > EWRAM = 0xFF
    __ewram_overlay_end = . ;

	.sbss ALIGN(4)(NOLOAD):
 	{
 		*(.sbss)
 		. = ALIGN(4);
 	} > EWRAM

    /DISCARD/ :
    {
        *(.ARM.exidx.*)
        *(.ARM.extab.*)
        *(.eh_frame)
        *(.gcc_except_table*)
        *(.rust_begin_unwind)
    }

    .ARM.attributes 0 : { KEEP (*(.ARM.attributes)) }
}
