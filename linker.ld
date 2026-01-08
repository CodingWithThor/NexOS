/* Plik: linker.ld */
ENTRY(loader)

SECTIONS
{
    /* Standard dla Multiboot: zaczynamy od 1MB pamięci fizycznej */
    . = 1M;

    .text :
    {
        *(.multiboot) /* Nagłówek musi być pierwszy! */
        *(.text)
    }

    .rodata : { *(.rodata) }
    .data   : { *(.data) }
    .bss    : { *(.bss) }
}