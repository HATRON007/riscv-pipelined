#include "bench.h"

#ifndef N
#define N 128
#endif

#ifndef REPEAT
#define REPEAT 2
#endif

/* 0: random shuffle, 1: sorted, 2: reversed, 3: nearly sorted */
#ifndef MODE
#define MODE 0
#endif

static int arr[N];

static void init_array(uint32_t *seed) {
    for (int i = 0; i < N; i++) {
#if MODE == 1
        arr[i] = i;
#elif MODE == 2
        arr[i] = (N - 1) - i;
#else
        arr[i] = i;
#endif
    }

#if MODE == 0
    for (int i = 0; i < N; i++) {
        uint32_t r = xorshift32(seed) & (N - 1);
        int tmp = arr[i];
        arr[i] = arr[r];
        arr[r] = tmp;
    }
#elif MODE == 3
    for (int i = 0; i < N - 1; i += 8) {
        int tmp = arr[i];
        arr[i] = arr[i + 1];
        arr[i + 1] = tmp;
    }
    (void)seed;
#else
    (void)seed;
#endif
}

int main(void) {
    uint32_t seed = 0x13579BDFu;
    uint32_t checksum = 0;

    for (int rep = 0; rep < REPEAT; rep++) {
        init_array(&seed);

        BENCH_START();
        for (int i = 0; i < N - 1; i++) {
            int limit = (N - 1) - i;
            for (int j = 0; j < limit; j++) {
                int a = arr[j];
                int b = arr[j + 1];
                if (a > b) {
                    arr[j] = b;
                    arr[j + 1] = a;
                }
            }
        }
        BENCH_STOP();

        for (int i = 0; i < N; i++) {
            checksum += (uint32_t)arr[i] << (i & 3);
        }
    }

    /* For N=128, sum_{i=0}^{127} (i << (i & 3)) = 30848 per repetition */
    uint32_t expected = 30848u * (uint32_t)REPEAT;
    BENCH_EXIT(checksum, expected);
}