# RV32-MIRA

A 5-stage pipelined 32-bit RISC-V (`RV32IM`) processor written from scratch in Verilog, with a bare-metal C runtime and cycle-accurate microarchitectural benchmarks.

## Microarchitecture

The core is a classical 5-stage pipeline (`IF`, `ID`, `EX`, `MEM`, `WB`) backed by separate 32 KB synchronous instruction and data SRAMs.

* **Forwarding and Interlocks:** Full `EX`-to-`EX` and `MEM`-to-`EX` bypass paths for ALU and store data. Load-use dependencies stall `IF` and `ID` for one cycle while injecting a bubble into `EX`. Because instruction memory is synchronous (1-cycle read latency), `proc_datapath` latches the fetched instruction into a hold register (`ins_hold`) whenever `ID` stalls so the instruction is not overwritten by the in-flight fetch.
* **Branch Prediction:** A 256-entry direct-mapped Branch Target Buffer (`branch_predictor.v`) indexed by `PC[9:2]` with 22-bit tags (`PC[31:10]`) and 2-bit saturating counters. Predictions are made in `IF` in a single cycle. Branch directions and targets are verified in `EX`; mispredictions squash `IF` and `ID`, incurring a 2-cycle penalty.
* **Iterative Multiplier:** A signed multi-cycle shift-and-add unit (`imul_top.v`) integrated into `EX` via a valid/ready handshake. Instead of shifting by 1 bit per cycle for 32 cycles, a priority encoder (`imul_counter.v`) locates the next set bit in the multiplier operand to skip runs of consecutive zeros in a single clock cycle, and terminates early once the remaining upper bits are zero.

## Verification

Verification is divided into directed RTL tests and compiled bare-metal C programs:

* `tb/tb_isa/`: Directed tests for `R-type`, `I-type`, byte/half/word load-store alignment and sign extension (`lsu_tb.v`), and `JAL`/`JALR` linking.
* `tb/tb_hz/`: Pipeline interlock tests for back-to-back RAW forwarding, load-use stalls, and speculative path flushing.
* `tb/tb_imul/`: Signed 2's complement boundary tests and variable-latency cycle checks.
* `tb/tb_bp/`: Loop training and saturating counter verification.
* `sw/`: Bare-metal C environment (`crt0.S`, `link.ld`) compiled with `riscv64-unknown-elf-gcc` (`-ffreestanding -nostdlib -mno-relax`).

## Branch Predictor Characterization

To measure the net pipeline impact of the 2-bit BTB without startup noise, `tb/tb_bench_bp.v` instantiates two cores in parallel on the same clock: one with the BTB enabled (`bp_on = 1`) and one configured as a static predict-not-taken baseline (`bp_on = 0`).

All benchmark arrays are allocated in `.bss` and initialized at runtime prior to measurement. Hardware performance counters are gated by memory-mapped writes to `0x7FF0` fenced with compiler memory barriers, isolating the kernel loops from `crt0.S` and checksum verification. All benchmarks are compiled with `-march=rv32i -O2` and `-fno-if-conversion` so conditional branches are not converted into branchless `slt` sequences.

| Workload | Dynamic Branches | Static (`bp_on=0`) Acc | 2-Bit BTB (`bp_on=1`) Acc | Cycles (`bp_on=0`) | Cycles (`bp_on=1`) | Cycles Saved | Speedup |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| `bp_sieve` ($N=1024, R=3$) | 12,672 | 28.76% | 94.08% | 68,541 | 51,987 | 16,554 | 24.15% |
| `bp_bubblesort` ($N=128, R=2$) | 32,766 | 24.03% | 83.50% | 163,322 | 124,350 | 38,972 | 23.86% |
| `bp_binsearch` ($N=512, Q=512, R=2$) | 21,506 | 50.01% | 71.20% | 131,076 | 121,960 | 9,116 | 6.95% |

**Observations:**
1. Across all three workloads, `Cycles Saved` equals `2 * (Misses_off - Misses_on)` to the exact cycle (`16,554 = 2 * 8,277`, `38,972 = 2 * 19,486`, `9,116 = 2 * 4,558`), confirming the 2-cycle `EX` resolution penalty and verifying that no non-branch stalls leaked into the timed window.
2. `bp_sieve` achieves 94.08% accuracy because its inner loop has a high trip count and its outer `if (!composite[i])` check is strongly biased (~83% of integers below 1024 are composite).
3. `bp_bubblesort` executes 16,383 loop branches (~99% predicted) and 16,383 data-dependent `a > b` comparisons on pseudo-random `xorshift32` permutations (~68% predicted), yielding 83.50% overall accuracy.
4. `bp_binsearch` exposes the expected limit of local 2-bit history: while the 9-iteration `while (low < high)` loop branch is learned, the `arr[mid] < key` direction branch is a 50/50 random step through the search tree, bounding overall accuracy to 71.20%.

## Repository Layout

```text
rtl/
  proc/       5-stage pipeline, hazard unit, 2-bit BTB, byte-addressable SRAM
  imul/       Iterative signed multiplier with zero-skipping counter
tb/
  tb_isa/     Instruction set directed tests
  tb_hz/      Forwarding, load-use, and flush tests
  tb_imul/    Multiplier sign and latency tests
  tb_bp/      Predictor loop test
  tb_core.v   Top-level C program runner
  tb_bench_bp.v Dual-core branch predictor benchmark harness
sw/
  runtime/    crt0.S and 32 KB linker script
  programs/   Standalone C programs (quicksort.c)
  bench/      Benchmark kernels and MMIO header (bench.h)
  Makefile    Cross-compilation and disassembly checks
