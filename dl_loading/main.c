#include <SDL/SDL.h>
#include <dlfcn.h>

void eval_dlerror(void) {
    char* msg = dlerror();
    if(msg)
        printf("DL_ERROR : %s\n", msg);
}

int main(int argc, char* argv[]) {

    void* fh = dlopen("/usr/lib/x86_64-linux-gnu/libSDL.so", RTLD_NOW);
    eval_dlerror();

    const char* function_list[] = {
        "SDL_Init",
        "SDL_Quit",
        "SDL_SetVideoMode",
        "SDL_Delay"
    };

    int i;
    for(i = 0; i < 4; i++) {
        void* addr = dlsym(fh, function_list[i]);

        eval_dlerror();
        printf("Address of %-20s: %p\n", function_list[i], addr);

    }

}
