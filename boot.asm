BITS 16

ORG 0x7C00

STAGE2_LOAD_ADDR equ 0x8000
STAGE2_SECTORS   equ 10
BOOT_DRIVE       equ 0x00
STAGE2_START_SECTOR equ 0x02

START:
    cli

    mov ax, 0x07C0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFE

    sti

    mov si, MESSAGE_TEXT
    call print_string

load_stage2:
    mov ah, 0x02
    mov al, STAGE2_SECTORS

    mov ch, 0x00
    mov cl, STAGE2_START_SECTOR
    mov dh, 0x00
    mov dl, BOOT_DRIVE

    mov bx, STAGE2_LOAD_ADDR
    mov es, bx

    int 0x13
    jc disk_error

    jmp 0x0000:STAGE2_LOAD_ADDR

print_string:
    lodsb
    or al, al
    jz print_done
    mov ah, 0x0E
    mov bh, 0x00
    int 0x10
    jmp print_string

print_done:
    ret

disk_error:
    mov si, ERROR_TEXT
    call print_string
    hlt
    jmp $

MESSAGE_TEXT db "NexOS Kernel Booting...", 0x0A, 0x0D, 0x00
ERROR_TEXT   db "Disk Read Error! Halting.", 0x0A, 0x0D, 0x00

times 510 - ($ - $$) db 0

dw 0xAA55