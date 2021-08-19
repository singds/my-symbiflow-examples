# this is a comment
# this only load the right stack pointer and jumps to main
# the startup section contains the first instruction executed by the core

.section .startup
# this is the first instruction executed
    la sp, _sstack 
    j main
