; ==================================
; NASM - Stage 2: Przejście do Protected Mode (32-bit)
; ==================================

BITS 16
ORG 0x8000 ; Stage 2 jest ładowany pod adres 0x8000

START_STAGE2:
    cli                    ; Wyłącz przerwania
    
    ; 1. Załadowanie GDT
    lgdt [GDT_PTR]
    
    ; 2. Włączenie Protection Enable (bit PE w CR0)
    mov eax, cr0
    or eax, 0x1           ; Ustaw bit 0 (PE)
    mov cr0, eax

    ; 3. Daleki skok (Far Jump) do kodu 32-bitowego
    ; Używamy deskryptora Code Segment 32-bitowego (Offset 0x08)
    jmp 0x08:PROTECTED_MODE_ENTRY

; ==================================
; GDT - Global Descriptor Table (dla Protected Mode)
; ==================================
GDT_START:
    ; 0. Null Descriptor (Offset 0x00)
    dd 0x0                  
    dd 0x0
    
CODE_DESC:
    ; 1. 32-bit Code Segment Descriptor (Offset 0x08)
    dw 0xFFFF               ; Limit (0-15)
    dw 0x0                  ; Base (0-15)
    db 0x0                  ; Base (16-23)
    db 10011010b            ; Access Byte: Present=1, Privl=0, Executable=1, R/W=1
    db 11001111b            ; Flags: Granularity=1, Size=1 (32-bit), Limit(16-19)
    db 0x0                  ; Base (24-31)

DATA_DESC:
    ; 2. 32-bit Data Segment Descriptor (Offset 0x10)
    dw 0xFFFF               ; Limit (0-15)
    dw 0x0                  ; Base (0-15)
    db 0x0                  ; Base (16-23)
    db 10010010b            ; Access Byte: Present=1, Privl=0, R/W=1
    db 11001111b            ; Flags: Granularity=1, Size=1 (32-bit), Limit(16-19)
    db 0x0                  ; Base (24-31)
GDT_END:

GDT_PTR:
    dw GDT_END - GDT_START - 1 ; Limit GDT (rozmiar - 1)
    dd GDT_START               ; Adres GDT

; ==================================
; Kod w trybie chronionym (32-bit)
; ==================================
BITS 32
PROTECTED_MODE_ENTRY:
    ; Ustawienie rejestrów segmentowych na deskryptor Danych (Offset 0x10)
    mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    ; Ustaw stos 32-bitowy
    mov esp, 0x90000 ; Ustawiamy stos na bezpieczny adres (np. 576 KB)

    ; W tej pętli jesteśmy już w 32-bit Protected Mode!
    jmp $
    
; Wypełnienie pliku Stage 2 (5120 bajtów)
times 5120 - ($ - $$) db 0