OUTPUT_ARCH( "riscv" )
ENTRY( _start )

MEMORY {
    ram (rwx) : ORIGIN = 0x00000000, LENGTH = 32K
}

SECTIONS {
    .text : {
        *(.text.init)
        *(.text*)
        . = ALIGN(4);
    } > ram

    .rodata : {
        *(.rodata*)
        *(.srodata*)
        . = ALIGN(4);
    } > ram

    .data : {
        __global_pointer$ = . + 0x800;
        *(.data*)
        *(.sdata*)
        . = ALIGN(4);
    } > ram

    .bss : {
        . = ALIGN(4);
        __bss_start = .;
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end = .;
    } > ram

    /* Reserve 0x7FF0..0x7FFC for benchmark MMIO */
    __stack_top = 0x00007FF0;
}