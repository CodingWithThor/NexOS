# 🚀 NexOS
### Eksperymentalne 64-bitowe Jądro (OSDev)

NexOS Kernel to ambitny projekt jądra systemu operacyjnego (OSDev), tworzony od podstaw z wykorzystaniem **Assembly (NASM)** i **C**. Celem projektu jest głęboka eksploracja niskopoziomowych mechanizmów systemowych i stworzenie funkcjonalnego jądra 64-bitowego.

---

## Kluczowe Cele i Aspiracje

| Cel | Opis |
| :--- | :--- |
| **Architektura** | Pełne wsparcie dla **x86-64 (Long Mode)**. |
| **Kompatybilność** | Analiza i implementacja wsparcia dla formatu plików wykonywalnych **.EXE** (Portable Executable) na poziomie jądra. |
| **Bezpieczeństwo (Anticheat)** | Opracowanie wbudowanego, jądrowego mechanizmu zabezpieczającego, monitorującego procesy na poziomie **Ring 0** (inspiracja architekturą systemów antycheat, takich jak Riot Vanguard). |

---

## Aktualny Status

Jądro jest obecnie w fazie wczesnego **bootstrappingu**.

* **Stan:** Działający 16-bitowy sektor rozruchowy (boot sector).
* **Technologie:** NASM (16-bit), QEMU.
* **Następny Krok:** Implementacja Stage 2 bootloadera i przełączanie do 64-bitowego Long Mode.