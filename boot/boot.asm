;memory is divided into physical chunks called "sectors." A standard sector holds exactly 512 bytes of data.
;Sector 0 is the absolute first chunk of data on the entire disk.
;the motherboard's BIOS doesn't know how to read files. It blindly reaches out to the USB drive, grabs only Sector 0,
;copies those 512 bytes into the computer's RAM at address 0x7C00, address 0x7C00 is the standard physical memory location where an x86 BIOS loads the Master Boot Record (MBR) or boot sector from a storage device
;and tells the CPU to start executing it.

;when NASM translates text into binary, it needs to know what era of CPU it's targeting. Since the BIOS wakes the computer up in Real Mode (16 bit)

bits 16 
;org stands for where exactly our code will be loaded.
org 0x7c00 ;the BIOS always loads us at exactly 0x7C00, we create a variable, NASM needs to know where in RAM this code will physically live so it can calculate the pointer.
