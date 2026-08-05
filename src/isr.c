#include "include/isr.h"
#include "include/vga_print.h"
void fault_handler(){
    print_string("A CPU Exception has occurred!\n");
    while(1); /*infinite loop to halt the system after a CPU exception. This prevents the system from continuing to run in an unstable state, which could lead to further errors or data corruption.*/
    
}