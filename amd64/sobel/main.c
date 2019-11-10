#include <stdio.h>
#include <stdlib.h>
#include "main.h"

// return value indicates what actually happened:
//  0 : algorithm did exactly what was expected
//  1 : algorithm attempted to perform SIMDx4 execution but was
//      unable to due to unavailable processor support
int sobel(double* src, double* dest, int h, int w, int flag);
void init_sobel(void);

//int apply_gp_sobel(double* src, double* dest, int h, int w);
int apply_simd_sobel(double* src, double* dest, int h, int w);

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

void print_result(int i) {
    switch(i) {
        case SOBEL_GENERAL_PURPOSE:
            puts("\tSOBEL_GENERAL_PURPOSE");
            break;
        case SOBEL_SIMD_OFFSET_1:
            puts("\tSOBEL_SIMD_OFFSET_1");
            break;
        default:
            puts("\tErroneous Sobel result");
            exit(1);
    }
}

int main(int argc, char* argv[]) {

    // asm routine builds up LUT for different ways of solving
    init_sobel();

    int iters = 0;
    unsigned long int start_time, total_time;
    int r;

    const int TOTAL_ITERS = 10000000;

    start_time = get_timestamp();
    for(iters = 0; iters < TOTAL_ITERS; iters++) {
        r = sobel(src, dest, 4, 4, SOBEL_GENERAL_PURPOSE);
    }
    total_time = get_timestamp() - start_time;
    printf("Total time: %12ld microseconds (GP Sobel)\n", total_time);
    print_result(r);

    start_time = get_timestamp();
    for(iters = 0; iters < TOTAL_ITERS; iters++) {
        r = sobel(src, dest, 4, 4, SOBEL_SIMD_OFFSET_1);
    }
    total_time = get_timestamp() - start_time;
    printf("Total time: %12ld microseconds (SIMD Sobel)\n", total_time);
    print_result(r);

    return 0;
}
