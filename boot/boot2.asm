;this file has the continuation of the bootloader code. It is loaded into memory at 0x7C00 by the BIOS, and then it loads the next stage of the bootloader from disk into memory at 0x8000, and jumps to it.
bits 16
org 0x8000 ;in the last boot.asm we loaded the next stage of the bootloader into memory at 0x8000, so the cpu will start executing here.
mov ah,0x0e ;BIOS command for "Write Character to Screen"
mov al,'A' ;the character we want to print
int 0x10 ;call the BIOS to print the character
halt_loop:
jmp $