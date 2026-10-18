@echo off
set RTL_FILES=^
  rtl/imul/imul_control.v ^
  rtl/imul/imul_counter.v ^
  rtl/imul/imul_datapath.v ^
  rtl/imul/imul_top.v ^
  rtl/proc/alu.v ^
  rtl/proc/hazard_unit.v ^
  rtl/proc/imm_gen.v ^
  rtl/proc/proc_control.v ^
  rtl/proc/proc_datapath.v ^
  rtl/proc/proc_top.v ^
  rtl/proc/regfile.v ^
  rtl/proc/sram.v ^
  rtl/proc/stage_ex.v ^
  rtl/proc/stage_id.v ^
  rtl/proc/stage_if.v ^
  rtl/proc/stage_mem.v ^
  rtl/proc/stage_wb.v ^
  rtl/proc/branch_predictor.v

@REM  echo [1/3] Running Bubble Sort Benchmark...
@REM  iverilog -o tb/sim.out %RTL_FILES% tb/tb_bench_bp.v
@REM  if %errorlevel% neq 0 exit /b %errorlevel%
@REM  vvp tb/sim.out

@REM  echo [2/3] Running Binary Search Benchmark...
@REM  iverilog -DBENCH_BINSEARCH -o tb/sim.out %RTL_FILES% tb/tb_bench_bp.v
@REM  if %errorlevel% neq 0 exit /b %errorlevel%
@REM  vvp tb/sim.out

@REM  echo [3/3] Running Sieve Benchmark...
@REM  iverilog -DBENCH_SIEVE -o tb/sim.out %RTL_FILES% tb/tb_bench_bp.v
@REM  if %errorlevel% neq 0 exit /b %errorlevel%
@REM  vvp tb/sim.out

echo [1/3] Running MatMul (WIDTH=8)...
iverilog -o tb/sim.out %RTL_FILES% tb/tb_bench_imul.v
if %errorlevel% neq 0 exit /b %errorlevel%
vvp tb/sim.out

echo [2/3] Running MatMul (WIDTH=16)...
iverilog -DBENCH_MATMUL_W16 -o tb/sim.out %RTL_FILES% tb/tb_bench_imul.v
if %errorlevel% neq 0 exit /b %errorlevel%
vvp tb/sim.out

echo [3/3] Running MatMul (WIDTH=32)...
iverilog -DBENCH_MATMUL_W32 -o tb/sim.out %RTL_FILES% tb/tb_bench_imul.v
if %errorlevel% neq 0 exit /b %errorlevel%
vvp tb/sim.out