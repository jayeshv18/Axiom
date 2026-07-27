;memory is divided into physical chunks called "sectors." A standard sector holds exactly 512 bytes of data.
;Sector 0 is the absolute first chunk of data on the entire disk.
;the motherboard's BIOS doesn't know how to read files. It blindly reaches out to the USB drive, grabs only Sector 0,
;copies those 512 bytes into the computer's RAM at address 0x7C00, address 0x7C00 is the standard physical memory location where an x86 BIOS loads the Master Boot Record (MBR) or boot sector from a storage device
;and tells the CPU to start executing it.

;when NASM translates text into binary, it needs to know what era of CPU it's targeting. Since the BIOS wakes the computer up in Real Mode (16 bit)

bits 16 
;org stands for where exactly our code will be loaded.
org 0x7c00 ;the BIOS always loads us at exactly 0x7C00, we create a variable, NASM needs to know where in RAM this code will physically live so it can calculate the pointer.

;to print to the screen in Real Mode,The BIOS has a series of built-in, primitive hardware drivers that we can trigger using Software Interrupts (specifically, int 0x10 for Video Services).

;the bios reads upto 512 bytes of data from the sector 0 as it can identify the 0xAA66 signature in the endof the sector.
;after that what? if we need to write a massive high-performance kernel, C—with a multitasking scheduler, memory management, and a Virtual File System, we are going to need way more than 512 bytes.
;like the BIOS has a video driver (int 0x10) that we used to print a single character, it also has a primitive disk driver: int 0x13.

;BIOS Disk Service: int 0x13.
;we need a safe, empty place in physical RAM to dump the boot stage 2 data, boot.asm is currently sitting at 0x7C00. It takes up 512 bytes (up to 0x7DFF).
;boot stage 2 code safely above it at address 0x8000.

;BIOS uses a two-part pointer called es:bx to define this destination. To be safe, must explicitly set the es (Extra Segment) register to 0 before we set bx to 0x8000

;firstly need to set ex to 0
mov ax,0x0000 
mov es,ax ;set the extra segment to 0
//the logic for using the es nd bx regs is written in "es and bx segment mapping limitation "
mov ah,0x02 ;BIOS command for "Read Sectors into Memory"
mov al,1;How many sectors do we want to read? Just 1 for now
mov ch,0 ;Cylinder 0
mov cl,2 ;Sector 2
mov dh,0;Head 0
mov bx,0x8000;memory address where we want the BIOS to put the data
int 0x13 ;call the BIOS to read the disk

;do not overwrite the dl register. When the computer boots, the BIOS automatically places the correct Boot Drive ID into dl. If we leave it alone, int 0x13 automatically knows which drive to read from.

jmp 0x8000 ;jump to the new code we just loaded into RAM
;'$$' means "the address where this section started" (0x7C00).
;($ - $$) calculates exactly how many bytes of code we have written so far.
;we subtract that from 510, and tell NASM to write exactly that many zeros (db 0).
times 510 - ($ - $$) db 0
;dw (define word) writes exactly 2 bytes. 
;because x86 reads data backwards (Little Endian architecture), 
;we write 0xAA55 so it physically lands on the disk as 55 AA.
dw 0xaa55