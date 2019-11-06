#include <stdio.h>
#include <SDL/SDL.h>

long int _main(void);

// not doing this causes a system crash EVERY F*CKING TIME I RUN THE PROGRAM!!!!
// these functions are wrappers for certain SDL functions
SDL_Surface* setvideomode(int width, int height, int bpp, unsigned long flags) {
    return SDL_SetVideoMode(width, height, bpp, flags); 
}

int main(int argc, char* argv[]) { 

    long int i = _main();
    printf("%ld\n", i);
    return 0; 

}
