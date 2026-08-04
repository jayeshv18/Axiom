;C cannot natively speak to the CPU's IDTR hardware register, we have to write a microscopic assembly function to do it for us.
global load_idt ;makes the label visible to the linker so C can call it.
extern idtp ;tells the assembler that the 6-byte pointer structure is defined in another file.

load_idt:
    lidt [idtp] ;load the IDT pointer into the CPU's IDTR register, Loads the Interrupt Descriptor Table register with the base and limit address.
    ret