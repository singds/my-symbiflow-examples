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
data_loop:
    beq x2, x3, init_bss
    lw x4, 0(x1)
    sw x4, 0(x2)
    addi x1, x1, 0x04
    addi x2, x2, 0x04
    j data_loop

# init bss section
# all data in the bss section must be zero inistialized
init_bss:
    la x1, _startBss
    la x2, _endBss
bss_loop:
    beq x1, x2, run_to_main
    sw x0, 0(x1)
    addi x1, x1, 0x04
    j bss_loop

# setup the stack pointer and run to main
run_to_main:
    la sp, _sstack 
    j main
