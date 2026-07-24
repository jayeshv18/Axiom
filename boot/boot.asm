;memory is divided into physical chunks called "sectors." A standard sector holds exactly 512 bytes of data.
;Sector 0 is the absolute first chunk of data on the entire disk.
;the motherboard's BIOS doesn't know how to read files. It blindly reaches out to the USB drive, grabs only Sector 0,
;copies those 512 bytes into the computer's RAM at address 0x7C00, address 0x7C00 is the standard physical memory location where an x86 BIOS loads the Master Boot Record (MBR) or boot sector from a storage device
;and tells the CPU to start executing it.

;when NASM translates text into binary, it needs to know what era of CPU it's targeting. Since the BIOS wakes the computer up in Real Mode (16 bit)

bits 16 
;org stands for where exactly our code will be loaded.
org 0x7c00 ;the BIOS always loads us at exactly 0x7C00, we create a variable, NASM needs to know where in RAM this code will physically live so it can calculate the pointer.
halt_loop:
;to print to the screen in Real Mode,The BIOS has a series of built-in, primitive hardware drivers that we can trigger using Software Interrupts (specifically, int 0x10 for Video Services).

mov ah,0x0e
mov al,'J'
int 0x10

;'$' means "the memory address of this exact line". 
;we are telling the CPU to jump to the line it's currently on, freezing it forever.
jmp $
;'$$' means "the address where this section started" (0x7C00).
;($ - $$) calculates exactly how many bytes of code we have written so far.
;we subtract that from 510, and tell NASM to write exactly that many zeros (db 0).
times 510 - ($ - $$) db 0
;dw (define word) writes exactly 2 bytes. 
;because x86 reads data backwards (Little Endian architecture), 
;we write 0xAA55 so it physically lands on the disk as 55 AA.
dw 0xaa55