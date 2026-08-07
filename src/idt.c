#include "include/idt.h"
#include "include/string.h"

extern void isr0(); /*declare the external assembly function isr0, which is defined in isr.asm. This function serves as the entry point for handling interrupt 0 (Divide by Zero Exception) and is responsible for saving the CPU state, calling the C fault_handler function, and restoring the CPU state before returning from the interrupt.*/
extern void load_idt();

struct idt_entry idt[256]; /*the IDT is an array of 256 entries, one for each possible interrupt number. Each entry contains the information needed to handle a specific interrupt.*/
struct idt_ptr idtp;/*the idtp structure holds the size and base address of the IDT. It is used to load the IDT into the CPU's IDTR register, allowing the CPU to locate and use the IDT when handling interrupts.*/

void idt_set_gate(unsigned char num, unsigned int base, unsigned short sel, unsigned char flags){
    idt[num].offset_low=base & 0xFFFF; /*the lower 16 bits of the address to jump to when this interrupt fires. This is done by performing a bitwise AND operation with 0xFFFF, which masks out the upper 16 bits of the base address.*/
    idt[num].selector=sel; /*the segment selector that points to the code segment in our GDT that contains the interrupt handler function. This tells the CPU which code segment to use when handling this interrupt.*/
    idt[num].zero=0; /*this must always be zero. It is reserved for future use by Intel and should not be modified.*/
    idt[num].type_attr=flags; /*this specifies the type and attributes of the interrupt gate. It defines how the CPU should handle the interrupt, including its privilege level and whether it is present in memory.*/
    idt[num].offset_high=(base>>16) & 0xFFFF; /*the upper 16 bits of the address to jump to when this interrupt fires. This is done by right-shifting the base address by 16 bits and performing a bitwise AND operation with 0xFFFF, which masks out any bits beyond the lower 16 bits.*/
}

void idt_init(){
    idtp.limit=sizeof(struct idt_entry)*256-1; /*the size of the array in bytes. set the limit of the IDT to the size of the IDT in bytes minus 1. This tells the CPU how many entries are in the IDT.*/
    idtp.base=(unsigned int)&idt; /*the physical memory address of the array. set the base address of the IDT to the address of the idt array. This tells the CPU where to find the IDT in memory.*/
    memory_set(&idt,0,sizeof(struct idt_entry)*256); /*initialize all entries in the IDT to zero. This ensures that any unused entries are set to a known state, preventing undefined behavior when an interrupt occurs.*/
    idt_set_gate(0, (unsigned int)isr0, 0x08, 0x8E);
    load_idt(); /*load the IDT into the CPU's IDTR register. This tells the CPU to use the newly initialized IDT when handling interrupts.*/
}