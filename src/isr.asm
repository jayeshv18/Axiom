;tiny assembly function that catches the CPU interrupt, saves all the current CPU registers to the stack (so we don't corrupt running code), calls our C function, restores the registers, and cleanly executes iret.
;the cpu has through go through this code to save the current context and then proceed to our C function, which will handle the interrupt. After the C function is done, we restore the CPU state and return from the interrupt.

;If the CPU jumps directly into a C function, that C function is going to start running its own logic. To run its logic, the C compiler will naturally overwrite the values in EAX and EBX.
;When the C function finishes, it returns to the cryptographic hash code but EAX and EBX have been destroyed. The hash is corrupted. The system collapses.
;We immediately execute pushad. This grabs the exact state of EAX, EBX, etc., and safely buries them in the RAM (the stack). This is a freeze-frame.
;Now it is safe to call C. C can destroy the CPU registers all it wants.
;When C finishes, we execute popad. This digs the original values out of RAM and puts them exactly back into EAX and EBX.
;We execute iret (Interrupt Return), and the original program resumes, completely unaware it was ever paused.

;When the CPU stops a program to execute an interrupt, it automatically pushes exactly three things onto the stack so it knows how to return later:
;[EIP] (Instruction Pointer)
;[CS] (Code Segment)
;[EFLAGS] (Status flags)

;But, for a few very specific, highly destructive errors (like a Page Fault - Exception 14), the CPU designers decided the OS needs more information to debug the crash. 
;So, before the CPU jumps to your airlock, it silently shoves a 4th item onto the stack: an Error Code.

;This breaks everything.

;If we want our C code to read the frozen CPU state, we have to point a C struct at the stack memory. C expects memory to be perfectly uniform and predictable.
;If Exception 0 fires: Stack has 3 items.
;If Exception 14 fires: Stack has 4 items.
;If we don't fix this, our C struct will read misaligned memory and give us garbage data.

;We are writing two NASM macros to force the stack to be uniform.
;If the CPU didn't give us an error code (ISR_NOERRCODE), our macro will inject a fake one (push 0) just to take up the 4 bytes of space.
;If the CPU did give us an error code (ISR_ERRCODE), our macro leaves it alone.

;By doing this, no matter which of the 32 exceptions fires, by the time it reaches the isr_common_stub, the memory layout is perfectly identical. We can safely pushad, jump to C, read the raw CPU state, and print the exact hexadecimal memory address that caused the kernel panic.

%macro ISR_NOERRCODE 1  ; The '1' means this macro takes 1 parameter
    global isr%1   ; '%1' gets replaced by whatever number you pass in
    isr%1:
        push 0 ;push a dummy error code onto the stack to maintain stack alignment
        push %1 ;push the error code onto the stack
        jmp isr_common_stub ;jump to the common interrupt handler
%endmacro

%macro ISR_ERRCODE 1  
    global isr%1   ; '%1' gets replaced by whatever number you pass in
    isr%1:
        push %1 ;push the error code onto the stack 
        jmp isr_common_stub ;jump to the common interrupt handler
%endmacro

global isr_common_stub ;it needs to expose our assembly stub to C so that idt_init can plug its memory address into Gate 0.
extern fault_handler ;in isr.c
isr_common_stub:
    pushad ;save all general-purpose registers
    call fault_handler ;call the C function
    popad ;restore all general-purpose registers
    add esp, 8 ;must clean up the 8 bytes we pushed for the error code and interrupt number before returning, otherwise iret will crash
    iret ;hardware interrupt return
