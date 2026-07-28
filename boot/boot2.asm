;this file has the continuation of the bootloader code. It is loaded into memory at 0x7C00 by the BIOS, and then it loads the next stage of the bootloader from disk into memory at 0x8000, and jumps to it.
bits 16
org 0x8000 ;in the last boot.asm we loaded the next stage of the bootloader into memory at 0x8000, so the cpu will start executing here.
mov ah,0x0e ;BIOS command for "Write Character to Screen"
mov al,'A' ;the character we want to print
int 0x10 ;call the BIOS to print the character

; Enable the A20 Line via Fast A20 Gate
in al, 0x92      ; Read the current state of the System Control Port into AL
or al, 2         ; Set the 2nd bit (bit 1) to 1 to enable A20
out 0x92, al     ; Write the modified byte back to the port

cli ;Clear Interrupts
lgdt [gdt_descriptor] ;Load Global Descriptor Table, square brackets mean "I don't want the literal memory address of this label, I want you to read the data stored inside it."

mov eax,cr0 ;physical switch to 32-bit Protected Mode is the 0th bit of Control Register 0
or eax,1 ;set bit 0 (Protected Mode Enable)
mov cr0,eax
;However, there is a massive architectural danger right here: The CPU Pipeline.Modern CPUs don't execute one instruction at a time; they read ahead and pre-load upcoming instructions into a pipeline to save time.
;when we flipped CR0, the CPU's pipeline was already full of 16-bit instructions that it pre-loaded. If it tries to execute them in 32-bit mode, it will immediately crash.We have to forcefully flush the pipeline.
;we do this by executing a Far Jump
;a Far Jump tells the CPU to jump to a new memory segment. When the CPU sees a segment change, it panics, dumps everything out of its pipeline, and re-reads the upcoming instructions using the new 32-bit laws.

jmp 0x08:init_pm
bits 32 ;tell NASM to stop generating 16-bit code and switch to 32-bit
init_pm:
;update all the old segment registers to point to our new 32-bit Data Segment
;the Data Segment is at offset 0x10 (16 bytes) in the GDT
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
jmp $

;GDT
gdt_start:
    gdt_null:
    ;safety net
        dd 0x0 ;dd (define double word) writes 4 bytes. We do it twice to get 8 bytes of zero.
        dd 0x0
    gdt_code:
    ;dw	Define Word	2 bytes (16 bits)	16-bit integers, memory offsets, Unicode chars
    ;db	Define Byte	1 byte (8 bits)	ASCII characters, small integers, strings
        dw 0xFFFF ;Limit Low (Bits 0-15 of the size)
        dw 0x0000 ;Base Low (Bits 0-15 of the starting address)
        db 0x00 ;Base Middle (Bits 16-23 of the starting address)
        db 10011010b ;Access Byte (Ring 0, Executable, Present)
        db 11001111b ;Flags (32-bit, 4KB Granularity) + Limit High (Bits 16-19)
        db 0x0 ;Base High (Bits 24-31 of the starting address)
    gdt_data:;this segment will hold C variables, arrays, and the stack
    ;its physical layout is an exact clone of the Code Segment (starting at 0x0, stretching out to 4GB).
    ;the only difference is the Access Byte, which must be changed to 10010010b to mark the memory as non-executable but writable.
        dw 0xFFFF
        dw 0x0000
        db 0x00
        db 10010010b
        db 11001111b
        db 0x0
gdt_end:;place a label here to mark the absolute end of the table

gdt_descriptor:
    dw gdt_end - gdt_start - 1 ;size of the GDT, minus 1 (null safety net)
    ; -1 isn't actually because of the null descriptor. It is a strange Intel hardware quirk. The maximum possible size of a GDT is 65,536 bytes.
    ;The problem? A 16-bit register (dw) can only count up to 65,535 (0xFFFF).
    ;To solve this, Intel hardcoded the CPU to always add 1 to whatever number you give it. So, we subtract 1 to balance the equation.
    dd gdt_start ;physical 32-bit starting address of our table