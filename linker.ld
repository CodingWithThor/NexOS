/* linker.ld */
ENTRY(kmain)
PHDRS { code PT_LOAD; }
SECTIONS {
    . = 0x9400; /* Ustawienie adresu startowego kodu C */
    .text : {
        *(.text)
        *(.rodata)
    } : code
    .data : {
        *(.data)
    }
    .bss : {
        *(.bss)
    }
}