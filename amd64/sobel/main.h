#ifndef main_h
#define main_h

#define SOBEL_GENERAL_PURPOSE 0x00000000
#define SOBEL_SIMD_OFFSET_1   0x00000001

#include <sys/time.h>

unsigned long int get_timestamp(void) {
    struct timeval tv;
    gettimeofday(&tv, NULL);

    return tv.tv_sec*1000000L + tv.tv_usec;
}

#endif // main_h
