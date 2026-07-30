#ifndef VGA_PRINT_H
#define VGA_PRINT_H

#define VGA_WIDTH 80
#define VGA_HEIGHT 25

void clear_screen();
void print_string(const char* str);
void scroll();

#endif