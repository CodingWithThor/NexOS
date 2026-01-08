void kernel_main() {
    volatile unsigned char* vga = (unsigned char*)0xB8000;

    const char* message = "NexOS: 64-bit Kernel Loaded Successfully!";
    
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        vga[i] = ' ';
        vga[i+1] = 0x07;
    }

    for (int i = 0; message[i] != '\0'; i++) {
        vga[i * 2] = message[i];
        vga[i * 2 + 1] = 0x0E;
    }

    while (1) {
        __asm__("hlt");
    }
}