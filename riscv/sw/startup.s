# this is a comment
# this only load the right stack pointer and jumps to main
# the startup section contains the first instruction executed by the core

.section .startup
# this is the first instruction executed

# copy inistialized data from rom to ram
# see linker script
    la x1, _srcStartData
    la x2, _dstStartData
    la x3, _dstEnddata
copy_loop:
    beq x2, x3, run_to_main
    lw x4, 0(x1)
    sw x4, 0(x2)
    addi x1, x1, 0x04
    addi x2, x2, 0x04
    j copy_loop

# setup the stack pointer and run to main
run_to_main:
    la sp, _sstack 
    j main
