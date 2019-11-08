#include <stdio.h>

void apply_sobel(double* src, double* dest, int h, int w);

#define ARR_SIZE 25

/*
double src[ARR_SIZE] = { // 16
    4.0, 4.0, 4.0, 4.0,
    3.0, 3.0, 3.0, 3.0,
    2.0, 2.0, 2.0, 2.0,
    1.0, 1.0, 1.0, 1.0
};
*/

/*
double src[ARR_SIZE] = { // 20
    4.0, 3.0, 2.0, 1.0, 0.0,
    4.0, 3.0, 2.0, 1.0, 0.0,
    4.0, 3.0, 2.0, 1.0, 0.0,
    4.0, 3.0, 2.0, 1.0, 0.0
};
*/

/*
double src[ARR_SIZE] = { // 25
    4.0, 3.0, 2.0, 1.0, 0.0,
    4.0, 3.0, 2.0, 1.0, 0.0,
    4.0, 3.0, 2.0, 1.0, 0.0,
    4.0, 3.0, 2.0, 1.0, 0.0,
    4.0, 3.0, 2.0, 1.0, 0.0
};
*/

double src[ARR_SIZE] = { // 25
    4.0, 4.0, 4.0, 4.0, 4.0,
    3.0, 3.0, 3.0, 3.0, 3.0,
    2.0, 2.0, 2.0, 2.0, 2.0,
    1.0, 1.0, 1.0, 1.0, 1.0,
    0.0, 0.0, 0.0, 0.0, 0.0
};

/*
    Sobel operator: 
        -1 -2 -1
         0  0  0
         1  2  1

    expect: 
        [
            -4 -8 -4 +0 +0 +0 +2 +4 +2 = -8   -8
            -3 -6 -3 +0 +0 +0 +1 +2 +1 = -8   -8
        ]
*/

double dest[ARR_SIZE] = {0.0};

int main(int argc, char* argv[]) {

    int h = 5;
    int w = 5;

    int j;
    for(j = 0; j < ARR_SIZE; j += w) {

        int k;
        for(k = 0; k < w; k++)
            printf("%-10lf ", src[j+k]);
        puts("");

    }
    
    apply_sobel(src, dest, h, w);
    puts("");

    for(j = 0; j < ARR_SIZE; j += w) {

        int k;
        for(k = 0; k < w; k++)
            printf("%-10lf ", dest[j+k]);
        puts("");

    }

    return 0;
}
