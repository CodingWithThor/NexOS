# ==========================================
# NexOS Makefile - Wersja dla Ubuntu / WSL2
# ==========================================

# Narzędzia
AS      = nasm
CC      = gcc
LD      = ld
GRUB    = grub-mkrescue
QEMU    = qemu-system-x86_64

# Pliki wejściowe i wynikowe
KERNEL_BIN = kernel.bin
ISO_OUT    = NexOS.iso
BOOT_OBJ   = boot.o
KERNEL_OBJ = kernel.o

# Flagi kompilacji (Kluczowe dla 64-bit jądra)
# -m64: Tryb 64-bitowy
# -ffreestanding: Brak standardowej biblioteki C
# -fno-stack-protector: Wyłącza ochronę stosu (nie mamy jej jeszcze w jądrze)
# -fno-pic / -fno-pie: Wyłącza kod niezależny od pozycji
# -mcmodel=kernel: Optymalizacja adresowania dla jądra
CFLAGS = -m64 -ffreestanding -fno-stack-protector -fno-pic -fno-pie -nostdlib -mcmodel=kernel

# Flagi linkera
# -m elf_x86_64: Linkowanie do formatu 64-bit ELF
# -T linker.ld: Użycie Twojego skryptu linkera
LDFLAGS = -m elf_x86_64 -T linker.ld

# Domyślny cel
all: $(ISO_OUT)

# 1. Asemblowanie bootloadera
$(BOOT_OBJ): boot.asm
	$(AS) -f elf64 boot.asm -o $(BOOT_OBJ)

# 2. Kompilacja jądra C
$(KERNEL_OBJ): kernel.c
	$(CC) $(CFLAGS) -c kernel.c -o $(KERNEL_OBJ)

# 3. Linkowanie jądra do pliku binarnego
$(KERNEL_BIN): $(BOOT_OBJ) $(KERNEL_OBJ)
	$(LD) $(LDFLAGS) $(BOOT_OBJ) $(KERNEL_OBJ) -o $(KERNEL_BIN)

# 4. Tworzenie obrazu ISO (wymaga grub-pc-bin i xorriso)
$(ISO_OUT): $(KERNEL_BIN) grub.cfg
	@echo "Budowanie obrazu ISO..."
	mkdir -p iso/boot/grub
	cp $(KERNEL_BIN) iso/boot/kernel.bin
	cp grub.cfg iso/boot/grub/grub.cfg
	$(GRUB) -o $(ISO_OUT) iso
	@echo "Gotowe: $(ISO_OUT)"

# Uruchomienie w emulatorze
run: $(ISO_OUT)
	$(QEMU) -cdrom $(ISO_OUT)

# Czyszczenie plików tymczasowych
clean:
	rm -rf *.o $(KERNEL_BIN) $(ISO_OUT) iso

.PHONY: all run clean