#include <stdio.h>

// there is an assembly routine with this name
int _main(void);

int main(int argc, char* argv[]) {

    long int result = _main();
    printf("Return value: %ld\n", result);

}
