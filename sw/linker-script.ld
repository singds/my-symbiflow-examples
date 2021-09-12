/*
LINKER RELAXATION, GLOBAL POINTER (gp) and SMALL SECTIONS (.sbss, .sdata, .srodata)

Linker relaxation is an optimization that permit to reduce the code size.
The x3 (gp) register can be used to store a fixed address that can be used to
access variables with relative addressing.
Accessing a generic symbol normally requires 2 instructions: one instructions to load
the upper part of the symbol's address in a register and a relative load or store.
Accessing a variable with relative addressing using gp base register requires
1 instruction only.
Symbols that can be addressed using gp must be in +-2K range near gp.
gp must be early initialized in the startup file and must not be changed during
program execution.
__global_pointer$ is usually placed 2K after the start of a small section so all
the offsets can be used to access symbols.
Note that relaxation must be disabled while setting gp, otherwise "la gp, __global_pointer$"
is relaxed by the linker in "mv gp, gp". See (.option norelax).

Linker relaxation is enabled by default (-mrelax is the default option).
You can disable linker relaxation in gcc using the -mno-relax option.

Small sections (.sbss .sdata .srodata) contains variables that have a size less
than o equal to 8 bytes.
When a variable size is <= 8 bytes the compiler, which from C code generates
assembly code, insted of putting the variable in .bss, .data or .rodata, puts
the variable in .sbss, .sdata, .srodata.
In this way __global_pointer$ can be placed near one of those sections to
optimise the access to the variables that the section contains.

The maximum size of variables that are placed in small sections can be changed
with -msmall-data-limit=n option.
Small sections can be disabled with -msmall-data-limit=0 option.
*/

MEMORY
{
    flash : ORIGIN = 0x00000000, LENGTH = 256
    ram : ORIGIN = 0x10000000, LENGTH = 256
}

stack_size = 100;

SECTIONS
{
    .mytext :
    {
        *(.startup)
        *(.text)
        *(.srodata)
        *(.rodata)
        . = ALIGN(4);
        _srcStartData = .;
    }> flash

    .mydata :
    {
        . = ALIGN(4);
        _dstStartData = .;

/*
you can define "__global_pointer$" symbol to enable linker relaxation
*/
       __global_pointer$ = (. + 2K - 8);

        *(.sdata)
        *(.data)
        . = ALIGN(4);
        _dstEnddata = .;
    }> ram AT> flash

    .mybss :
    {
        . = ALIGN(4);
        _startBss = .;
        *(.bss)
        *(COMMON)
        . = ALIGN(4);
        _endBss = .;
        _estack = .;
        . = . + stack_size;
        . = ALIGN(4);
        _sstack = .;
    }> ram
}
