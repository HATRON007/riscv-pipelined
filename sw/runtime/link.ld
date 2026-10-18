OUTPUT_ARCH( "riscv" )
ENTRY( _start )

/* 8192 words * 4 bytes = 32KB */
MEMORY {
    ram (rwx) : ORIGIN = 0x00000000, LENGTH = 32K
}

SECTIONS {
    .text : {
        *(.text.init)
        *(.text*)
    } > ram

    .data : {
        *(.data*)
        *(.rodata*)
        *(.sdata*)
    } > ram

    .bss : {
        __bss_start = .;
        *(.bss*)
        *(.sbss*)
        *(COMMON)
        __bss_end = .;
    } > ram

    /* Set stack pointer to 0x8000 (32KB) */
    __stack_top = ORIGIN(ram) + LENGTH(ram);
}