#include "include/vga_print.h"
//global tracking variables for the cursor position and the video memory address
int cursor_row = 0;
int cursor_col = 0;
char* video_memory = (char*) 0xB8000;

void clear_screen() {
    //loop through all 2000 cells (80x25)
    for(int i=0;i<=1999;i++){
        video_memory[i*2] = ' ';
        video_memory[i*2+1] = 0x0F; //0x0F is the color code for white text on black background.
    }
    //reset cursor to top-left
    cursor_row = 0;
    cursor_col = 0;
}

void scroll(){
    for(int i=0;i<VGA_WIDTH * (VGA_HEIGHT - 1);i++){
        //inside this loop, you are currently standing at cell i. The data you want to copy is sitting in the cell exactly one row beneath you.
        video_memory[i*2]=video_memory[(i + VGA_WIDTH) * 2]; //move the next line up to the current line
        video_memory[i*2 + 1] = video_memory[(i + VGA_WIDTH) * 2 + 1]; //move the color byte up to the current line
        //two lines of C code inside this loop to take the character byte and the color byte from i + VGA_WIDTH and assign them to i. (multipling the indices by 2 to satisfy the hardware contract).
    }
    //Once that first loop finishes, everything has shifted up. Row 1 became Row 0. Row 24 became Row 23. But Row 24 also still exists at the very bottom of the screen, leaving a duplicate line of text.
    //We need to clear that last line, so we will loop through the last row and set all of its characters to spaces.
    for(int i=1920;i<2000;i++){
        video_memory[i*2] = ' '; //set the character byte to a space
        video_memory[i*2+1] = 0x0F; //set the color byte to white on black
        //to wipe the bottom row clean.
    }
    cursor_row = 24; //reset the cursor to the last row
    cursor_col = 0; //reset the cursor last row col first.
}

void print_string(const char* str){
    //need to loop through the str array until we hit the null terminator
    while(*str!='\0'){ //check if the current character is a newline
        if(*str=='\n'){
            cursor_col = 0;
            cursor_row++;
        }else{
            int index=(cursor_row*VGA_WIDTH + cursor_col)*2; //calculate the index in the video memory
            video_memory[index] = *str; //set the current character in video memory
            video_memory[index+1] = 0x0F; //set the color attribute (Assigning chosen color hex code)
            cursor_col++; //move the cursor to the right
        }
        //statement to check the boundaries.
        if(cursor_col >= VGA_WIDTH){ //check if we need to wrap to the next line
            //if cursor_col is greater than or equal to 80, set cursor_col back to 0 and increment the cursor_row by 1.
            cursor_col = 0;
            cursor_row++;
        }
        if(cursor_row >= VGA_HEIGHT){ //check if we need to scroll the screen
            scroll(); //call the scroll function to move all lines up by one
        }
        str++; //move to the next character in the string
        //cause we used *str deferencing, we need to increment the pointer to point to the next character in the string.
    }

}