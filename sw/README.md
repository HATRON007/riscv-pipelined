# sw

C benchmarks that run on the core. Build and run instructions are in the [main README](../README.md#usage).

## Contents

```text
bench/      benchmark programs and bench.h (start/stop and result macros)
runtime/    crt0.S (startup code) and link.ld (32 KB linker script)
hexgen.py   converts the compiled binary into a .mem file for the memories
Makefile
```

| Benchmark | Tests |
| :--- | :--- |
| `bp_bubblesort`, `bp_binsearch`, `bp_sieve` | Branch predictor |
| `imul_matmul_w8`, `imul_matmul_w16`, `imul_matmul_w32` | Multiplier |

## How a benchmark runs

1. The program is compiled for `rv32i` (`rv32i_zmmul` for the multiplier programs) and linked with `crt0.S` and `link.ld`. The Makefile fails if the result contains an instruction the core does not implement, such as `div`, `mulh` or `ecall`.
2. `hexgen.py` converts the binary into a `.mem` file, which is loaded into the instruction and data memories at the start of the simulation.
3. The core executes the program. Each testbench simulates two cores on the same program: with and without the branch predictor, or with the fixed-latency and the variable-latency multiplier.

## How the result is checked

Each program computes one 32-bit number from its result, called the **signature**, and compares it with an expected value written in the source. For example, `bp_sieve` counts the primes below 1024: 172 per pass and 3 passes, so the signature must be 516 (`0x204`).

The program reports to the testbench by storing to four fixed addresses:

| Address | Meaning |
| :--- | :--- |
| `0x7FF0` | Timing window: 1 at the start of the measured code, 0 at the end |
| `0x7FF4` | The signature |
| `0x7FF8` | Status: 1 if the signature matched the expected value |
| `0x7FFC` | Done: the program has finished |

These are not real hardware. They are ordinary store addresses that the testbench watches. Cycles and instructions are counted only while the timing window is open, so startup code and the final check are not included.

A benchmark passes only if both cores report status 1 with the same signature. The branch predictor benchmarks also require that the cycles saved equal exactly 2x the mispredictions avoided.
