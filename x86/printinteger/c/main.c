#include <stdio.h>

int main(void) {
    // reference to the asm function with the same name
    extern void print_int(int,int,int);

    int i,j,k;
    for(i = 0; i < 14; i += 14) {
        for(j = 0; j < 14; j += 14) {
            for(k = 0; k < 100; k += 19) {
                print_int(i, j, k);
                puts("");
            }
        }
        //print_int(i, i+1, i+2);
        //puts("");
    }

}