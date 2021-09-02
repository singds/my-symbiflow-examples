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
        *(.data)
        *(.sdata)
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
