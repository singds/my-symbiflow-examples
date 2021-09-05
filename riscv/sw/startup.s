# this is a comment

# register's alternative names
# x0 = zero
# x1 = ra (return address)
# x2 = sp (stack pointer)
# x3 = gp (global pointer)
# x4 = tp (thread pointer)
# x5-7 = t0-2 (temporary registers)
# x8 = s0 / fp (saved register / frame pointer)
# x9 = s1 (saved register)
# x10-11 = a0-1 (function arguments / return values)
# x12-17 = a2-7 (function arguments)
# x18-27 = s2-11 (saved registers)
# x28-31 = t3-6 (temporary registers)

# The startup section contains the first instruction executed by the core.
# This section has the following tasks:
# - If linker relaxation is used (__global_pointer$ symbol is defined in the linker
#   script), initialize the gp register with __global_pointer$ address.
#   gp register is not initialized in this startup so linker relaxation must
#   be disabled: __global_pointer$ must not be defined in the linker script.
#   For more informations about linker relaxation and gp see the linker script.
#   Note that relaxation must be disabled while setting gp, otherwise
#   "la gp, __global_pointer$" is relaxed by the linker in "mv gp, gp".
#   See (.option norelax)
# - Initialize (.bss) memory section with zero values.
# - Initialize (.data) memory section with initial values stored in persistent storage.
# - Initialize the the stack pointer.
# - Jump to main.

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
