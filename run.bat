@echo off
echo ==================================================
echo [1/3] Compiling RISC-V Processor...
echo ==================================================

:: Windows cmd.exe cannot expand wildcards (*.v) for Icarus Verilog.
:: We list all files explicitly so Windows knows exactly what to compile:
iverilog -o sim/sim.out ^
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
  rtl/proc/branch_predictor.v ^
  tb/tb_top.v

:: Check if compilation failed
if %errorlevel% neq 0 (
    echo.
    echo [-] COMPILATION FAILED! Check the errors above.
    exit /b %errorlevel%
)

echo.
echo ==================================================
echo [2/3] Running Simulation...
echo ==================================================

:: Run the compiled simulation
vvp sim/sim.out

echo.
echo ==================================================
echo [3/3] Opening GTKWave...
echo ==================================================

:: Open GTKWave in the background
start gtkwave processor_waves.vcd

echo [+] Done!