#include "bench.h"

#define N 16

#ifndef WIDTH
#define WIDTH 8
#endif

#if WIDTH == 8
#define MASK 0x000000FFu
#define EXPECTED_SIG 0xf6d8881eu
#elif WIDTH == 16
#define MASK 0x0000FFFFu
#define EXPECTED_SIG 0xb03c04cbu
#else
#define MASK 0x7FFFFFFFu
#define EXPECTED_SIG 0xd45bbca0u
#endif

static int32_t A[N][N];
static int32_t B[N][N];
static int32_t C[N][N];

static void init_matrices(uint32_t *seed) {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            A[i][j] = (int32_t)(xorshift32(seed) & 0xFFFFu);
            B[i][j] = (int32_t)(xorshift32(seed) & MASK);
        }
    }
}

int main(void) {
    uint32_t seed = 0x9E3779B9u;
    init_matrices(&seed);

    BENCH_START();
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            int32_t acc = 0;
            for (int k = 0; k < N; k++) {
                acc += hw_mul(A[i][k], B[k][j]);
            }
            C[i][j] = acc;
        }
    }
    BENCH_STOP();

    uint32_t hash = 0x811C9DC5u;
    for (int i = 0; i < N; i++) {
        for (int j = 0; j < N; j++) {
            hash = ((hash << 5) | (hash >> 27)) ^ (uint32_t)C[i][j];
        }
    }

    BENCH_EXIT(hash, EXPECTED_SIG);
}