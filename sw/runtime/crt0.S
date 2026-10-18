.section .text.init
.global _start

_start:
    /* Initialize stack pointer */
    la sp, __stack_top

    /* Clear BSS section */
    la t0, __bss_start
    la t1, __bss_end
1:
    bgeu t0, t1, 2f
    sw zero, 0(t0)
    addi t0, t0, 4
    j 1b
2:
    /* Jump to C main */
    call main

_halt:
    /* Trap CPU on exit */
    j _halt