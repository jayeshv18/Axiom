/*
When an interrupt fires, the CPU blindly looks for a table in memory. It grabs the interrupt number (let's say 14 for a Page Fault), 
multiplies it by 8 bytes, and jumps to that specific location in the table to find the address of the C function it should run.
If that table isn't there, or if the 8-byte entry is formatted incorrectly, the CPU panics and Triple Faults.

The x86 processor supports exactly 256 different interrupts.

0 to 31 are hardwired by Intel for CPU Exceptions (e.g., 0 is Divide by Zero, 14 is Page Fault).
32 to 255 are free for us to map to hardware (like the keyboard) or software system calls.
*/

struct idt_entry{
    unsigned short offset_low; /*the lower 16 bits of the address to jump to when this interrupt fires*/
    unsigned short selector; /*the segment selector that points to the code segment in our GDT that contains the interrupt handler function*/
    unsigned char zero; /*this must always be zero. It is reserved for future use by Intel and should not be modified.*/
    unsigned char type_attr; /*this specifies the type and attributes of the interrupt gate. It defines how the CPU should handle the interrupt, including its privilege level and whether it is present in memory.*/
    unsigned short offset_high; /*the upper 16 bits of the address to jump to when this interrupt fires*/
} __attribute__((packed));

struct idt_ptr{
    unsigned short limit; /*the size of the IDT in bytes minus 1. The CPU uses this value to determine the bounds of the IDT and ensure that it doesn't access memory beyond its allocated space.*/
    unsigned int base; /*the linear address where the IDT starts in memory. The CPU uses this address to locate the IDT when an interrupt occurs.*/
} __attribute__((packed));

void idt_init(); /*initialize the IDT by setting up its entries and loading it into the CPU's IDTR register. This prepares the system to handle interrupts correctly.*/

/*The x86 processor has a dedicated, internal hardware register called the IDTR. Its only job is to store the location and size of IDT.*/

