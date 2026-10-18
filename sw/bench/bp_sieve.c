#include "bench.h"

#ifndef LIMIT
#define LIMIT 1024
#endif

#ifndef REPEAT
#define REPEAT 3
#endif

static uint8_t composite[LIMIT];

static void clear_sieve(void) {
    for (int i = 0; i < LIMIT; i++) {
        composite[i] = 0;
    }
}

int main(void) {
    uint32_t total_primes = 0;

    for (int rep = 0; rep < REPEAT; rep++) {
        clear_sieve();

        BENCH_START();
        for (int i = 2; i < LIMIT; i++) {
            if (!composite[i]) {
                total_primes++;
                for (int j = i + i; j < LIMIT; j += i) {
                    composite[j] = 1;
                }
            }
        }
        BENCH_STOP();
    }

    /* pi(1024) = 172 primes per pass */
    uint32_t expected = 172u * (uint32_t)REPEAT;
    BENCH_EXIT(total_primes, expected);
}