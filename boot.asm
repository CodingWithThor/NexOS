; Plik: boot.asm
bits 32                         ; Startujemy w trybie 32-bitowym (standard Multiboot)

section .multiboot
align 4
    dd 0x1BADB002               ; Magic number dla Multiboot
    dd 0x00                     ; Flagi
    dd -(0x1BADB002 + 0x00)     ; Checksum (Magic + Flags + Checksum musi dać 0)

section .text
global loader
extern kernel_main

loader:
    mov esp, stack_top          ; Ustawienie stosu dla jądra

    ; --- Przygotowanie Pagingu (Identity Mapping 0-2MB) ---
    ; W 64-bitach stronicowanie jest obowiązkowe.
    mov eax, pdpt_table
    or eax, 0b11                ; Flagi: Present + Writable
    mov [pml4_table], eax

    mov eax, pd_table
    or eax, 0b11
    mov [pdpt_table], eax

    mov eax, 0x000000           ; Mapujemy adres fizyczny 0x0
    or eax, 0b10000011          ; Present + Writable + Huge Page (2MB)
    mov [pd_table], eax

    ; --- Włączenie Long Mode (64-bit) ---
    mov eax, pml4_table
    mov cr3, eax                ; Załaduj adres PML4 do rejestru sterującego CR3

    mov eax, cr4
    or eax, 1 << 5              ; Włącz PAE (Physical Address Extension)
    mov cr4, eax

    mov ecx, 0xC0000080         ; Numer rejestru EFER
    rdmsr
    or eax, 1 << 8              ; Ustaw bit LME (Long Mode Enable)
    wrmsr

    mov eax, cr0
    or eax, 1 << 31             ; Włącz Paging (PG bit)
    mov cr0, eax

    lgdt [gdt64.pointer]        ; Załaduj nową, 64-bitową tablicę GDT
    jmp gdt64.code:long_mode    ; Skok daleki, aby odświeżyć rejestr CS

bits 64
long_mode:
    mov ax, 0x0                 ; Wyzerowanie rejestrów segmentowych
    mov ss, ax
    mov ds, ax
    mov es, ax

    call kernel_main            ; Wywołanie Twojego kodu w C
    hlt                         ; Zatrzymaj procesor, jeśli jądro powróci

section .bss
align 4096
pml4_table: resb 4096
pdpt_table: resb 4096
pd_table:   resb 4096
stack_bottom: resb 4096 * 4     ; 16KB miejsca na stos
stack_top:

section .rodata
gdt64:
    .null: dq 0
    .code: equ $ - gdt64
        dq (1<<43) | (1<<44) | (1<<47) | (1<<53) ; Deskryptor kodu
    .data: equ $ - gdt64
        dq (1<<44) | (1<<47) | (1<<41)           ; Deskryptor danych
    .pointer:
        dw $ - gdt64 - 1
        dq gdt64