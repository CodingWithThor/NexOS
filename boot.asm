ORG 0x7C00

START:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov si, MESSAGE_TEXT
    call print_string

    jmp $

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

MESSAGE_TEXT db "NexOS Booting...", 0x0A, 0x0D, 0x00

times 510 - ($ - $$) db 0

dw 0xAA55