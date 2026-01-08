// Plik: kernel.c

void kernel_main() {
    // Adres pamięci VGA: 0xB8000
    // Każdy znak to 2 bajty (ASCII + Kolor)
    volatile unsigned char* vga = (unsigned char*)0xB8000;

    const char* message = "NexOS: 64-bit Kernel Loaded Successfully!";
    
    // Proste czyszczenie ekranu (80 kolumn x 25 wierszy)
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        vga[i] = ' ';
        vga[i+1] = 0x07; // Biały na czarnym
    }

    // Wypisanie tekstu
    for (int i = 0; message[i] != '\0'; i++) {
        vga[i * 2] = message[i];
        vga[i * 2 + 1] = 0x0E; // Żółty kolor
    }

    // Pętla trzymająca jądro przy życiu
    while (1) {
        __asm__("hlt");
    }
}