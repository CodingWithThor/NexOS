# NexOS
### Experimental 64-bit Kernel (OSDev)

NexOS Kernel is an ambitious operating-system-kernel project (OSDev), built from scratch using **Assembly (NASM)** and **C**. The goal of the project is to deeply explore low-level system mechanisms and create a functional 64-bit kernel.

---

## Key Goals and Aspirations

| Goal | Description |
| :--- | :--- |
| **Architecture** | Full support for **x86-64 (Long Mode)**. |
| **Compatibility** | Research and implementation of **.EXE (Portable Executable)** executable format support directly at the kernel level. |
| **Security (Anticheat)** | Development of an integrated kernel-level security mechanism that monitors processes in **Ring 0** (inspired by architectures of anticheat systems like Riot Vanguard). |

---

## Current Status

The kernel is currently in an early **bootstrapping** phase.

- **Status:** Fully functioning 16-bit boot sector  
- **Technologies:** NASM (16-bit), QEMU  
- **Next Step:** Implementing the Stage 2 bootloader and switching to 64-bit Long Mode
```
