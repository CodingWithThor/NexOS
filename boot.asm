; ==================================
; NASM - Stage 1: Ładowanie Stage 2
; ==================================

BITS 16               ; Używamy trybu 16-bitowego

ORG 0x7C00            ; BIOS ładuje sektor rozruchowy pod ten adres

; Stałe dla ładowania Stage 2
STAGE2_LOAD_ADDR equ 0x8000  ; Adres, gdzie załadujemy Stage 2 (32 KB)
STAGE2_SECTORS   equ 10      ; Liczba sektorów Stage 2 (5 KB)
BOOT_DRIVE       equ 0x00    ; Numer napędu (najczęściej 0x00 dla FDD w QEMU)
STAGE2_START_SECTOR equ 0x02 ; Sektor 1 to bootloader, więc Stage 2 zaczyna się od Sektora 2

START:
    cli                   ; Wyłącz przerwania
    
    ; Ustawienie segmentów na standardową wartość BIOS-u 0x07C0
    mov ax, 0x07C0        
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFE        ; Ustawienie wierzchołka stosu na wysoki adres
    
    sti                   ; Włącz przerwania

    ; --- Wyświetlenie komunikatu (przez funkcję BIOS, int 0x10) ---
    mov si, MESSAGE_TEXT
    call print_string

    ; --- Ładowanie Stage 2 z dysku ---
    
load_stage2:
    mov ah, 0x02              ; Funkcja: Odczytaj sektory (Read Sectors)
    mov al, STAGE2_SECTORS    ; AL = Liczba sektorów do odczytu (10)
    
    mov ch, 0x00              ; CH = Cylinder 0
    mov cl, STAGE2_START_SECTOR ; CL = Sektor startowy (Sektor 2)
    mov dh, 0x00              ; DH = Głowica 0
    mov dl, BOOT_DRIVE        ; DL = Numer napędu (0x00)
    
    mov bx, STAGE2_LOAD_ADDR  ; BX = Offset docelowy
    mov es, bx                ; ES:BX = Adres docelowy (0x0000:0x8000)
    
    int 0x13                  ; Wywołanie przerwania odczytu dysku
    jc disk_error             ; Skok, jeśli wystąpił błąd

    ; --- Przejście do Stage 2 ---
    jmp 0x0000:STAGE2_LOAD_ADDR ; Daleki skok do wczytanego kodu Stage 2 (ważne jest DS:OFF)
    
; ==================================
; Funkcja drukowania ciągu znaków i obsługa błędów
; ==================================
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

; ==================================
; Dane i Wypełnienie
; ==================================

MESSAGE_TEXT db "NexOS Kernel Booting...", 0x0A, 0x0D, 0x00
ERROR_TEXT   db "Disk Read Error! Halting.", 0x0A, 0x0D, 0x00

; Wypełnienie do 510 bajtów
times 510 - ($ - $$) db 0

; Sygnatura Bootloadera
dw 0xAA55