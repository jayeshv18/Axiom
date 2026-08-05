;tiny assembly function that catches the CPU interrupt, saves all the current CPU registers to the stack (so we don't corrupt running code), calls our C function, restores the registers, and cleanly executes iret.
;the cpu has through go through this code to save the current context and then proceed to our C function, which will handle the interrupt. After the C function is done, we restore the CPU state and return from the interrupt.

global isr0 ;it needs to expose our assembly stub to C so that idt_init can plug its memory address into Gate 0.
extern fault_handler
isr0:
    pushad ;save all general-purpose registers
    call fault_handler ;call the C function
    popad ;restore all general-purpose registers
    iret ;hardware interrupt return