AS      = nasm
CC      = gcc
LD      = ld
GRUB    = grub-mkrescue
QEMU    = qemu-system-x86_64

KERNEL_BIN = kernel.bin
ISO_OUT    = NexOS.iso
BOOT_OBJ   = boot.o
KERNEL_OBJ = kernel.o

CFLAGS = -m64 -ffreestanding -fno-stack-protector -fno-pic -fno-pie -nostdlib -mcmodel=kernel

LDFLAGS = -m elf_x86_64 -T linker.ld

all: $(ISO_OUT)

$(BOOT_OBJ): boot.asm
	$(AS) -f elf64 boot.asm -o $(BOOT_OBJ)

$(KERNEL_OBJ): kernel.c
	$(CC) $(CFLAGS) -c kernel.c -o $(KERNEL_OBJ)

$(KERNEL_BIN): $(BOOT_OBJ) $(KERNEL_OBJ)
	$(LD) $(LDFLAGS) $(BOOT_OBJ) $(KERNEL_OBJ) -o $(KERNEL_BIN)

$(ISO_OUT): $(KERNEL_BIN) grub.cfg
	@echo "Budowanie obrazu ISO..."
	mkdir -p iso/boot/grub
	cp $(KERNEL_BIN) iso/boot/kernel.bin
	cp grub.cfg iso/boot/grub/grub.cfg
	$(GRUB) -o $(ISO_OUT) iso
	@echo "Gotowe: $(ISO_OUT)"

run: $(ISO_OUT)
	$(QEMU) -cdrom $(ISO_OUT)

clean:
	rm -rf *.o $(KERNEL_BIN) $(ISO_OUT) iso

.PHONY: all run clean