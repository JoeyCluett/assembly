ENTRY(loader)

SECTIONS {

    /*. = 0x00100000;*/
    . = 0x00000000;

    .data ALIGN (0x1000) : { /* align constant data on a 4KB boundary */
        *(.data)             /* all data sections from all files */
    }

    .text ALIGN (0x1000) : { /* align instruction code in a 4KB boundary */
        *(.text)             /* all instruction code sections from all files */
    }

    .rodata ALIGN (0x1000) : { /* align read-only data on a 4KB boundary */
        *(.rodata)             /* all read-only sections from all files */
    }

    .bss ALIGN (0x1000) : { /* align uninit'ed data on a 4KB boundary */
        *(COMMON)
        *(.bss)
    }

}
