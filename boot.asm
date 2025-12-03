; ==================================
; NASM - Stage 1: Ładowanie Stage 2 i Jądra C
; ==================================

BITS 16               
ORG 0x7C00            

; --- Stałe Ładowania ---
STAGE2_LOAD_ADDR equ 0x8000  ; Adres, gdzie załadujemy Stage 2
STAGE2_SECTORS   equ 20      ; CAŁKOWITA liczba sektorów (Stage 2 + Kernel C)
BOOT_DRIVE       equ 0x00    
STAGE2_START_SECTOR equ 0x02 ; Stage 2 zaczyna się od Sektora 2

START:
    cli                   
    
    ; Ustawienie segmentów
    mov ax, 0x07C0        
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0xFFFE        
    
    sti                   

    ; --- Wyświetlenie komunikatu ---
    mov si, MESSAGE_TEXT
    call print_string

    ; --- Ładowanie Stage 2 + Jądro C z dysku (Standardowy CHS) ---
    
load_stage2:
    mov ah, 0x02              ; Funkcja: Odczytaj sektory
    mov al, STAGE2_SECTORS    ; AL = Liczba sektorów do odczytu (20)
    
    mov ch, 0x00              ; CH = Cylinder 0
    mov cl, STAGE2_START_SECTOR ; CL = Sektor startowy (Sektor 2)
    mov dh, 0x00              ; DH = Głowica 0
    mov dl, BOOT_DRIVE        ; DL = Numer napędu
    
    mov bx, STAGE2_LOAD_ADDR  ; BX = Offset docelowy (0x8000)
    mov es, bx                ; ES:BX = Adres docelowy
    
    int 0x13                  ; Wywołanie przerwania odczytu dysku
    jc disk_error             
    
    ; Upewnienie się co do adresu skoku
    mov ax, 0x0000
    mov es, ax
    mov bx, STAGE2_LOAD_ADDR  ; BX = 0x8000
    
    ; Przekazanie kontroli do wczytanego kodu Stage 2
    jmp 0x0000:STAGE2_LOAD_ADDR 
    
; ==================================
; Funkcja drukowania i obsługa błędów
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

MESSAGE_TEXT db "NexOS Kernel Booting...", 0x0A, 0x0D, 0x00
ERROR_TEXT   db "Disk Read Error! Halting.", 0x0A, 0x0D, 0x00

times 510 - ($ - $$) db 0
dw 0xAA55