; =======================================================
; NASM - Stage 2: Przejście do Long Mode (64-bit) i skok do C
; =======================================================

BITS 16
ORG 0x8000 

; --- Stałe Pagingu ---
PML4_ADDR  equ 0x9000
PDPT_ADDR  equ 0xA000
PD_ADDR    equ 0xB000

; Adres startowy kodu C (0x8000 + 5120 bajtów Stage 2)
KERNEL_C_START_ADDR equ 0x9400 

START_STAGE2:
    cli                    
    
    ; 1. Załadowanie GDT
    lgdt [GDT_PTR]
    
    ; 2. Włączenie Protection Enable (PE) w CR0
    mov eax, cr0
    or eax, 0x1           
    mov cr0, eax

    ; 3. Daleki skok (Far Jump) do kodu 32-bitowego (offset 0x08)
    jmp 0x08:PROTECTED_MODE_ENTRY

; =======================================================
; GDT - Global Descriptor Table
; =======================================================
GDT_START:
    ; 0. Null Descriptor (Offset 0x00)
    dd 0x0, 0x0
    
CODE_DESC_32:
    ; 1. 32-bit Code Segment (Offset 0x08)
    dw 0xFFFF, 0x0, 0x0 
    db 10011010b            
    db 11001111b            
    db 0x0
DATA_DESC:
    ; 2. 32-bit Data Segment (Offset 0x10)
    dw 0xFFFF, 0x0, 0x0 
    db 10010010b            
    db 11001111b            
    db 0x0

CODE_DESC_64:
    ; 3. 64-bit Code Segment (Offset 0x18)
    dd 0x0                  
    db 0x9A                 
    db 0xA0                 
    dd 0x0

GDT_END:
GDT_PTR:
    dw GDT_END - GDT_START - 1 
    dd GDT_START               

; =======================================================
; Kod w trybie chronionym (32-bit)
; =======================================================
BITS 32
PROTECTED_MODE_ENTRY:
    ; Ustawienie rejestrów segmentowych na deskryptor Danych (Offset 0x10)
    mov ax, 0x10
    mov ds, ax      ; POPRAWNA SKŁADNIA
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000 

    ; --- 1. Konfiguracja Pagingu (mapowanie 2MB) ---
    mov edi, PML4_ADDR
    mov ecx, 1024 / 4 
    xor eax, eax
    cld
    rep stosd

    mov dword [PML4_ADDR], PDPT_ADDR | 0b11 
    mov dword [PDPT_ADDR], PD_ADDR | 0b11   
    mov edi, PD_ADDR
    mov dword [edi], 0x0 | 0b10000011 

    ; --- 2. Przejście do Long Mode ---
    mov eax, PML4_ADDR
    mov cr3, eax
    
    mov eax, cr4
    or eax, 0x20       ; Włączenie PAE (bit 5)
    mov cr4, eax
    
    mov ecx, 0xC0000080 ; MSR EFER
    rdmsr
    or eax, 0x100      ; Włączenie LME (bit 8)
    wrmsr

    mov eax, cr0
    or eax, 0x80000001 ; Włączenie Pagingu (bit 31)
    mov cr0, eax

    ; --- 3. Daleki skok do kodu 64-bitowego ---
    jmp 0x18:LONG_MODE_ENTRY 

; =======================================================
; Kod w trybie długim (64-bit)
; =======================================================
BITS 64
LONG_MODE_ENTRY:
    ; Ustawienie stosu 64-bitowego
    mov ax, 0x10       
    mov ss, ax         
    mov rsp, 0x100000  ; Stos ustawiony na 1MB

    ; --- SKOK DO JĄDRA C ---
    mov rax, KERNEL_C_START_ADDR 
    jmp rax         
    
    ; Jeśli jądro C zwróci kontrolę
    cli
    hlt
    jmp $
    
; Wypełnienie pliku Stage 2
times 5120 - ($ - $$) db 0