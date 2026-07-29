int main(){
    char* video_memory = (char*)0xB8000; //pointer to the start of video memory for text mode, further information about this can be found at Theory.txt
    video_memory[0] = 'X';
    video_memory[1] = 0x0F; //0x0F is the color code for white text on black background, further information about this can be found at Theory.txt
    return 0;
}