#include <stdio.h>

void apply_sobel(double* src, double* dest, int h, int w);

double src[16] = {
    1.0, 1.0, 1.0, 1.0,
    1.0, 1.0, 1.0, 1.0,
    1.0, 1.0, 1.0, 1.0,
    1.0, 1.0, 1.0, 1.0
};

double dest[16] = {0.0};

int main(int argc, char* argv[]) {

    printf("Addr of array: %p\n", (void*)src);
    apply_sobel(src, dest, 4, 4);

    

    return 0;
}
