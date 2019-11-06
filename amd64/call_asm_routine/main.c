#include <stdio.h>

// add_ints is defined in the asm file
long int add_ints(long int* data, int sz);

int main(int argc, char* argv[]) {

    long int arr[6] = { 6, 5, 4, 3, 2, 1 };

    printf("sum: %ld\n", add_ints(arr, 6));

    return 0;
}
