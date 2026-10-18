#include "bench.h"

#ifndef N
#define N 512
#endif

#ifndef Q
#define Q 512
#endif

#ifndef REPEAT
#define REPEAT 2
#endif

static int arr[N];
static int keys[Q];

static void init_data(uint32_t *seed) {
    for (int i = 0; i < N; i++) {
        arr[i] = i << 1;
    }
    for (int i = 0; i < Q; i++) {
        keys[i] = i;
    }
    for (int i = 0; i < Q; i++) {
        uint32_t r = xorshift32(seed) & (Q - 1);
        int tmp = keys[i];
        keys[i] = keys[r];
        keys[r] = tmp;
    }
}

static inline __attribute__((always_inline)) int binsearch(int key) {
    int low = 0;
    int high = N - 1;

    while (low < high) {
        int mid = (low + high) >> 1;
        if (arr[mid] < key) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }

    if (arr[low] == key) {
        return low;
    }
    return -1;
}

int main(void) {
    uint32_t seed = 0x2468ACE1u;
    int32_t checksum = 0;

    for (int rep = 0; rep < REPEAT; rep++) {
        init_data(&seed);

        BENCH_START();
        for (int i = 0; i < Q; i++) {
            checksum += binsearch(keys[i]);
        }
        BENCH_STOP();
    }

    /* 256 even keys hit indices 0..255 (sum=32640), 256 odd keys miss (-256) */
    int32_t expected = 32384 * REPEAT;
    BENCH_EXIT((uint32_t)checksum, (uint32_t)expected);
}