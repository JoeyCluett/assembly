#include <stdio.h>
#include "main.h"

// return value indicates what actually happened:
//  0 : algorithm did exactly what was expected
//  1 : algorithm attempted to perform SIMDx4 execution but was
//      unable to due to unavailable processor support
int sobel(double* src, double* dest, int h, int w, int flag);

//void apply_gp_sobel(double* src, double* dest, int h, int w);
//void apply_simd_sobel(double* src, double* dest, int h, int w);

#define ARR_SIZE 16
int h = 4;
int w = 4;

// this needs to be aligned because the SIMD routine requires aligned memory fetches
// i know its a lot of work on top of using raw asm routines but thats life sometimes y'know?
double __attribute__((aligned(32)))
        src[ARR_SIZE+1] = { // 16 (but technically 17)
    4.0, 4.0, 4.0, 4.0,
    3.0, 3.0, 3.0, 3.0,
    2.0, 2.0, 2.0, 2.0,
    1.0, 1.0, 1.0, 1.0,

    -1.0 // last value is simply to prevent segfault when using the AVX instructions
};

/*
    Sobel operator:
        -1 -2 -1
         0  0  0
         1  2  1
*/

double dest[ARR_SIZE] = {0.0};

void reset_dest(void) {
    int i;
    for(i = 0; i < ARR_SIZE; i++)
        dest[i] = 0.0;
}

void print_dest(void) {
    int i;
    for(int i = 0; i < ARR_SIZE; i += w) {
        int k;
        for(k = 0; k < w; k++)
            printf("%-10lf ", dest[i+k]);
        puts("");
    }
}

int main(int argc, char* argv[]) {

    int iters = 0;
    unsigned long int start_time, total_time;

    const int TOTAL_ITERS = 10000000;

    start_time = get_timestamp();
    for(iters = 0; iters < TOTAL_ITERS; iters++) {
        //reset_dest();
        sobel(src, dest, 4, 4, SOBEL_GENERAL_PURPOSE);
        //apply_gp_sobel(src, dest, 4, 4);
    }
    total_time = get_timestamp() - start_time;
    printf("Total time: %12ld microseconds (GP Sobel)\n", total_time);

    start_time = get_timestamp();
    for(iters = 0; iters < TOTAL_ITERS; iters++) {
        //reset_dest();
        sobel(src, dest, 4, 4, SOBEL_SIMD_OFFSET_1);
        //apply_simd_sobel(src, dest, 4, 4);
    }
    total_time = get_timestamp() - start_time;
    printf("Total time: %12ld microseconds (SIMD Sobel)\n", total_time);

    return 0;
}
