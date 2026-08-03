/*
an integer variable int error_code = 123; and you try to push that directly into your video_memory array, the hardware will not print "123". 
Instead, it will look up the value 123 on the ASCII table, see that it corresponds to the { symbol, and print a bracket to the screen.

To print 123, we have to mathematically chop the number into individual single digits (1, 2, and 3), 
convert each of those raw digits into their respective ASCII character bytes ('1', '2', '3'), and store them in a character array so print_string() can read them.
*/

#include "string.h"
void int_to_string(int num, char* str){
    int i=0;
    if(num==0){
        str[i++]='0'; /* the character '0' to the first position of the string (str[0]).The post-increment operator (i++) then increases i to 1. */
        str[i]='\0'; /*the null-terminator character (\0) at str[1].This properly closes the C-style string.*/
        return;
    }

    //negative int handle
    int is_negative = 0; /*flag to indicate if the number is negative*/
    if(num<0){
        is_negative=1; /*set the flag to indicate that the number is negative*/
        num=-num; /*convert the number to its positive equivalent*/
    }

    while(num>0){
        int last_digit=num%10; /*extract the last digit of the number by calculating the remainder when divided by 10*/
        str[i++]=last_digit+'0'; /*convert the last digit to its ASCII character representation by adding '0' (the ASCII value of '0') and store it in the string*/
        num/=10; /*remove the last digit from the number by performing integer division by 10*/
    }

    int start=0; /*initialize a variable start to 0, which will be used to reverse the string*/
    int end=i-1; /*initialize a variable end to i-1, which represents the index of the last character in the string (excluding the null-terminator)*/
    while(start<end){
        char temp=str[start]; /*store the character at the start index in a temporary variable temp*/
        str[start]=str[end]; /*swap the character at the start index with the character at the end index*/
        str[end]=temp; /*assign the value of temp (the original character at the start index) to the end index, completing the swap*/
        start++; /*increment the start index to move towards the center of the string*/
        end--; /*decrement the end index to move towards the center of the string*/
    }

    if(is_negative){
        str[i++]='-'; /*append the negative sign '-' to the string if the original number was negative*/
    }


    str[i] = '\0'; /*append the null-terminator character (\0) to the end of the string to mark its end*/

}