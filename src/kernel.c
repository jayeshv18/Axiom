#include "include/vga_print.h"
#include "include/idt.h"
#include "include/string.h"
int main(){
    idt_init();
    clear_screen();
    print_string("Hello, World!\n");
    __asm__ volatile ("int $0");
    return 0;
}