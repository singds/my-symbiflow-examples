# useful instructions

RISC-V Assembly Programmer's Manual  
https://github.com/riscv/riscv-asm-manual/blob/master/riscv-asm.md  
  
compile assembly code  
/opt/riscv32i/bin/riscv32-unknown-elf-gcc main.S -o out.elf

get a section as hex file  
/opt/riscv32i/bin/riscv32-unknown-elf-objcopy -j.text -O ihex out.elf out.hex  

