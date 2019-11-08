#include <stdio.h>

void apply_simd_sobel(double* src, double* dest, int h, int w);

#define ARR_SIZE 16
int h = 4;
int w = 4;

// this needs to be aligned because the SIMD routine requires aligned memory fetches
double __attribute__((aligned(16))) 
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

int main(int argc, char* argv[]) {

    int j;
    for(j = 0; j < ARR_SIZE; j += w) {

        int k;
        for(k = 0; k < w; k++)
            printf("%-10lf ", src[j+k]);
        puts("");

    }
    
    apply_simd_sobel(src, dest, h, w);
    puts("");

    for(j = 0; j < ARR_SIZE; j += w) {

        int k;
        for(k = 0; k < w; k++)
            printf("%-10lf ", dest[j+k]);
        puts("");

    }

    return 0;
}
