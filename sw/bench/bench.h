#ifndef BENCH_H
#define BENCH_H

#include <stdint.h>

#ifdef HOST_RUN
#include <stdio.h>
#include <stdlib.h>
#define BENCH_START()   do {} while (0)
#define BENCH_STOP()    do {} while (0)
#define BENCH_EXIT(sig, exp) do { \
    printf("sig=%d expected=%d status=%s\n", (int)(sig), (int)(exp), ((sig) == (exp)) ? "PASS" : "FAIL"); \
    return ((sig) == (exp)) ? 0 : 1; \
} while (0)
#else
#define MMIO_WINDOW (*(volatile uint32_t *)0x7FF0)
#define MMIO_SIG    (*(volatile uint32_t *)0x7FF4)
#define MMIO_STATUS (*(volatile uint32_t *)0x7FF8)
#define MMIO_DONE   (*(volatile uint32_t *)0x7FFC)

#define BENCH_START() do { \
    __asm__ volatile("" ::: "memory"); \
    MMIO_WINDOW = 1; \
    __asm__ volatile("" ::: "memory"); \
} while (0)

#define BENCH_STOP() do { \
    __asm__ volatile("" ::: "memory"); \
    MMIO_WINDOW = 0; \
    __asm__ volatile("" ::: "memory"); \
} while (0)

#define BENCH_EXIT(sig, exp) do { \
    __asm__ volatile("" ::: "memory"); \
    MMIO_SIG    = (uint32_t)(sig); \
    MMIO_STATUS = ((uint32_t)(sig) == (uint32_t)(exp)) ? 1u : 0u; \
    MMIO_DONE   = 1u; \
    __asm__ volatile("j ."); \
    __builtin_unreachable(); \
} while (0)
#endif

static inline __attribute__((always_inline)) uint32_t xorshift32(uint32_t *state) {
    uint32_t x = *state;
    x ^= x << 13;
    x ^= x >> 17;
    x ^= x << 5;
    *state = x;
    return x;
}

#endif