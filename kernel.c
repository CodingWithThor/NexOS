// kernel.c
void kmain() {
    // Adres pamięci tekstowej (text mode) w trybie VGA
    unsigned short* video_memory = (unsigned short*)0xB8000; 

    const char* message = "64-bit C Kernel Launched!";
    
    // Zapis do pamięci VGA: Biały tekst (0x0F) na czarnym tle
    for (int i = 0; message[i] != '\0'; i++) {
        video_memory[i] = (0x0F << 8) | message[i]; 
    }

    // Pętla nieskończona
    while(1) {}
}