OUTPUT_FORMAT("binary")

SECTIONS
{
    /*start the kernel at exactly 0x8200 */
    . = 0x8200;

    /*place the execution code first */
    .text : { 
        *(.text) 
    }

    /*place initialized variables immediately after */
    .data : { 
        *(.data) 
    }

    /*place static strings immediately after */
    .rodata : { 
        *(.rodata) 
    }

    /*place uninitialized variables immediately after */
    .bss : { 
        *(COMMON)
        *(.bss) 
    }
}