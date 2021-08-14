# useful instructions

RISC-V Assembly Programmer's Manual  
https://github.com/riscv/riscv-asm-manual/blob/master/riscv-asm.md  

RV32i-opcodes
https://github.com/riscv/riscv-opcodes/blob/master/opcodes-rv32i
  
compile assembly code  
/opt/riscv32i/bin/riscv32-unknown-elf-as main.S -o build/out.elf

disassembly code to see instruction hex values
/opt/riscv32i/bin/riscv32-unknown-elf-objdump --disassemble -Mnumeric build/out.elf  

get a section as hex file  
/opt/riscv32i/bin/riscv32-unknown-elf-objcopy -j.text -O ihex build/out.elf build/out.hex  

open waveforms with gtkwave
gtkwave build/soc_test.vcd &
