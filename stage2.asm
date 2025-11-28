BITS 16
ORG 0x8000

PML4_ADDR  equ 0x9000
PDPT_ADDR  equ 0xA000
PD_ADDR    equ 0xB000

START_STAGE2:
    cli

    lgdt [GDT_PTR]

    mov eax, cr0
    or eax, 0x1
    mov cr0, eax

    jmp 0x08:PROTECTED_MODE_ENTRY

GDT_START:
    dd 0x0, 0x0

CODE_DESC_32:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10011010b
    db 11001111b
    db 0x0

DATA_DESC:
    dw 0xFFFF
    dw 0x0
    db 0x0
    db 10010010b
    db 11001111b
    db 0x0

CODE_DESC_64:
    dd 0x0
    db 0x9A
    db 0xA0
    dd 0x0

GDT_END:

GDT_PTR:
    dw GDT_END - GDT_START - 1
    dd GDT_START

BITS 32
PROTECTED_MODE_ENTRY:
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000

    mov edi, PML4_ADDR
    mov ecx, 1024 / 4
    xor eax, eax
    cld
    rep stosd

    mov dword [PML4_ADDR], PDPT_ADDR | 0b11

    mov dword [PDPT_ADDR], PD_ADDR | 0b11

    mov edi, PD_ADDR
    mov dword [edi], 0x0 | 0b10000011

    mov eax, PML4_ADDR
    mov cr3, eax

    mov eax, cr4
    or eax, 0x20
    mov cr4, eax

    mov ecx, 0xC0000080
    rdmsr
    or eax, 0x100
    wrmsr

    mov eax, cr0
    or eax, 0x80000001
    mov cr0, eax

    jmp 0x18:LONG_MODE_ENTRY

BITS 64
LONG_MODE_ENTRY:
    mov ax, 0x10
    mov ss, ax
    mov rsp, 0x90000

    hlt
    jmp $

times 5120 - ($ - $$) db 0