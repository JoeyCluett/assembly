#include <stdio.h>

void apply_sobel(double* src, double* dest, int h, int w);

double src[16] = {
    4.0, 4.0, 4.0, 4.0,
    3.0, 3.0, 3.0, 3.0,
    2.0, 2.0, 2.0, 2.0,
    1.0, 1.0, 1.0, 1.0
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

double dest[16] = {0.0};

int main(int argc, char* argv[]) {

    printf("Addr of array: %p\n", (void*)src);
    apply_sobel(src, dest, 4, 4);

    puts("");

    int j;
    for(j = 0; j < 16; j += 4) {
        printf("%lf %lf %lf %lf\n", dest[j+0], dest[j+1], dest[j+2], dest[j+3]);
    }

    return 0;
}
