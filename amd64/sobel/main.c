#include <stdio.h>
#include <stdlib.h>
#include "main.h"

// return value indicates what actually happened:
//  0 : algorithm did exactly what was expected
//  1 : algorithm attempted to perform SIMDx4 execution but was
//      unable to due to unavailable processor support
int sobel(volatile double* src, volatile double* dest, int h, int w, int flag);
void init_sobel(void);

#define ARR_SIZE 288
volatile int h = 12;
volatile int w = 24;

// this needs to be aligned because the SIMD routine requires aligned memory fetches
// i know its a lot of work on top of using raw asm routines but thats life sometimes y'know?
volatile double __attribute__((aligned(32)))
        src[ARR_SIZE+1] = {
    4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0,
    3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
    2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0,
    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
    4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0,
    3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
    2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0,
    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
    4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0,
    3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0, 3.0,
    2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0, 2.0,
    1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,

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

int sobel_c(volatile double* src, volatile double* dest, int h, int w);

int main(int argc, char* argv[]) {

    // asm routine builds up LUT for different ways of solving
    init_sobel();

    int iters = 0;
    unsigned long int start_time, total_time;
    int r;

    const int TOTAL_ITERS = 1000000;

    int i;
    for(i = 0; i < 10; i++) {

    start_time = get_timestamp();
    for(iters = 0; iters < TOTAL_ITERS; iters++) {
        r = sobel(src, dest, h, w, SOBEL_GENERAL_PURPOSE);
    }
    total_time = get_timestamp() - start_time;
    printf("Total time: %12ld microseconds (GP Sobel)\n", total_time);
    //print_result(r);
    //print_dest();
    }
/*
    start_time = get_timestamp();
    for(iters = 0; iters < TOTAL_ITERS; iters++) {
        r = sobel(src, dest, h, w, SOBEL_SIMD_OFFSET_1);
    }
    total_time = get_timestamp() - start_time;
    printf("\n\nTotal time: %12ld microseconds (SIMD Sobel)\n", total_time);
    //print_result(r);
    print_dest();
*/

    puts("");

    for(i = 0; i < 10; i++) {

    start_time = get_timestamp();
    for(iters = 0; iters < TOTAL_ITERS; iters++) {
        //r = sobel(src, dest, h, w, SOBEL_SIMD_OFFSET_1);
        r = sobel_c(src, dest, h, w);
    }
    total_time = get_timestamp() - start_time;
    printf("Total time: %12ld microseconds (C Sobel)\n", total_time);
    //print_result(r);
    //print_dest();
    }

    return 0;
}

int sobel_c(volatile double* src_, volatile double* dest_, int h, int w) {
    
    int i, j;
    
    for(j = 1; j < h-1; j++) {
        for(i = 1; i < w-1; i++) {


            double t = 0.0;

            t += (-1.0*src_[(j-1)*w + (i-1)]);
            t += (-2.0*src_[(j-1)*w + (i)]);
            t += (-1.0*src_[(j-1)*w + (i+1)]);
            t +=  (0.0*src_[(j)*w   + (i)]);
            t +=  (0.0*src_[(j)*w   + (i)]);
            t +=  (0.0*src_[(j)*w   + (i)]);
            t +=  (1.0*src_[(j+1)*w + (i-1)]);
            t +=  (2.0*src_[(j+1)*w + (i)]);
            t +=  (1.0*src_[(j+1)*w + (i+1)]);

            dest_[j*w + i] = t;

        }
    }

    return 1;

}
