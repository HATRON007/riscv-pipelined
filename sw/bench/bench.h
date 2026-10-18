#ifndef BENCH_H
#define BENCH_H

#include <stdint.h>

#ifdef HOST_RUN
#include <stdio.h>
#include <stdlib.h>
#define BENCH_START()   do {} while (0)
#define BENCH_STOP()    do {} while (0)
#define BENCH_EXIT(sig, exp) do { \
    printf("sig=%u expected=%u status=%s\n", (uint32_t)(sig), (uint32_t)(exp), ((uint32_t)(sig) == (uint32_t)(exp)) ? "PASS" : "FAIL"); \
    return ((uint32_t)(sig) == (uint32_t)(exp)) ? 0 : 1; \
} while (0)

static inline int32_t hw_mul(int32_t a, int32_t b) {
    return a * b;
}
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

static inline __attribute__((always_inline)) int32_t hw_mul(int32_t a, int32_t b) {
    int32_t res;
    __asm__ volatile ("mul %0, %1, %2" : "=r"(res) : "r"(a), "r"(b));
    return res;
}
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