See prerequisites section before doing all kind of stuff.  

This folder contains the resources needed to build software for the little risc v core.  

Edit main.c and run `make`.  
This creates **build/** directory with **rom.v** file you can include as rom software memory in verilog design.  
**rom/** folder contains some prebuild example rom.  
`make compile_only` compiles **main.c** producing **build/main.s** you can you to inspect assembly code produced by gcc.


# prerequisites
You need to install:
- python3 with the needed libraries
```bash
sudo apt update
sudo apt install python3

# python libraries
pip3 install intelhex
```

- rv32i risc-v toolchain (a gcc compiler for this architecture).  
You can use a prebuild toolchain or compile it from sources. This last option can take you hours depending on your pc configuration.  
For a [prebuild toolchain](https://github.com/stnolting/riscv-gcc-prebuilt) :
```bash
wget https://github.com/stnolting/riscv-gcc-prebuilt/releases/download/rv32i-2.0.0/riscv32-unknown-elf.gcc-10.2.0.rv32i.ilp32.newlib.tar.gz

mkdir rv32i-toolchain
tar -xzf riscv32-unknown-elf.gcc-10.2.0.rv32i.ilp32.newlib.tar.gz -C rv32i-toolchain

export TC=$(pwd)/rv32i-toolchain
```