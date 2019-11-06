#include <stdio.h>

void call_user_function(void) {

    puts("hello from call_user_function");

}

void print_long(long i) {
    printf("%ld\n", i);
}

long int add_13(long i) {
    return i+13;
}
