# introduction

This is a simple project realized for the three-year degree in INGEGNERIA INFORMATICA at Università di Padova.
Graduation date: 23-07-2021.
The main purpose of this project is to demonstrait how a very simple processore can be created.
This processor is not really useful for other than educational purposes.

See the prerequisites section before start executing any command.



# hardware

## This section assumes you are inside the **hw** folder (`cd hw`).  
**hw** contains the processor Verilog sources and tests.  
**hw/test/** contains testbenches that tests single core components and the soc as a whole.
**soc_test.v** tests the whole soc with a running software.  
  
This project is created for the [Arty 35T](https://www.xilinx.com/products/boards-and-kits/arty.html) board although could be adapted for other boards.  
  
Enable the symbiflow environment before running commands.
If you have installed symbiflow as in the prerequisites section you can execute [runthis-env.sh](runthis-env.sh) script to enter the environment.

Run `make` to build the fpga bitstream.  
When **Synthesis** and **Place & route** have soccessfully finished you can find the bitstream in **build/** directory (top.bit).  

Run `make test` to compile and run tests with iverilog.

Run `make clean` to remove the **build** directory with all its content.

Connect the board with usb and run `make run` to load the bitstream in the FPGA and see your design running.



# software

## This section assumes you are inside the **sw** folder (`cd sw`).  
**sw** contains the resources needed to build software for the little risc v core.  
  
Edit main.c and run `make`.  
This creates **build/** directory with **rom.v** file you can include as rom software memory in verilog design.  
**rom/** folder contains some prebuild example rom.

Inside linker [linker script](sw/linker-script.ld) and [startup file](sw/startup.s) you can find useful and interesting informations about the use of global pointer and linker relaxation.

# prerequisites

To be able to produce FPGA bitstream and run tests you need to install:

-   **symbiflow**.
    You can follow the [official tutorial](https://symbiflow-examples.readthedocs.io/en/latest/getting-symbiflow.html).
    the installation procedure may change because the project is rapidly evolving.  
    Just report my installation commands for convenience:

    ```bash
    cd riscv-core

    apt update -y
    apt install -y git wget xz-utils

    git clone https://github.com/SymbiFlow/symbiflow-examples
    cd symbiflow-examples
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O conda_installer.sh
    # choose the install directory 
    export INSTALL_DIR=~/opt/symbiflow
    # select your target FPGA family
    export FPGA_FAM=xc7
    # setup Conda and your system’s environment
    bash conda_installer.sh -u -b -p $INSTALL_DIR/$FPGA_FAM/conda;
    source "$INSTALL_DIR/$FPGA_FAM/conda/etc/profile.d/conda.sh";
    conda env create -f $FPGA_FAM/environment.yml
    # download architecture definitions
    mkdir -p $INSTALL_DIR/xc7/install
    wget -qO- https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/367/20210822-000315/symbiflow-arch-defs-install-709cac78.tar.xz | tar -xJC $INSTALL_DIR/xc7/install
    wget -qO- https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/367/20210822-000315/symbiflow-arch-defs-xc7a50t_test-709cac78.tar.xz | tar -xJC $INSTALL_DIR/xc7/install
    wget -qO- https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/367/20210822-000315/symbiflow-arch-defs-xc7a100t_test-709cac78.tar.xz | tar -xJC $INSTALL_DIR/xc7/install
    wget -qO- https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/367/20210822-000315/symbiflow-arch-defs-xc7a200t_test-709cac78.tar.xz | tar -xJC $INSTALL_DIR/xc7/install
    wget -qO- https://storage.googleapis.com/symbiflow-arch-defs/artifacts/prod/foss-fpga-tools/symbiflow-arch-defs/continuous/install/367/20210822-000315/symbiflow-arch-defs-xc7z010_test-709cac78.tar.xz | tar -xJC $INSTALL_DIR/xc7/install
    ```
    If the above commands exited without errors, you have successfully installed and configured your working environment.


-   **iverilog** (Icarus Verilog).
    You need to compile it from sources because the version provided by your distribution is probably too old.
    Follow the instructions on the official github repo README.  
    Just report my installation commands for convenience:

    ```bash
    cd riscv-code

    sudo apt update
    sudo apt install make gcc bison gperf autoconf flex

    git clone https://github.com/steveicarus/iverilog.git
    cd iverilog
    sh autoconf.sh
    ./configure
    make

    make install
    ```

    To be able to compile code and produce rom content for the core you need to install:

-   **rv32i risc-v toolchain** (a gcc compiler for this architecture).  
    You can use a prebuild toolchain or compile it from sources.
    This last option can take you hours depending on your pc configuration.  
    For a [prebuild toolchain](https://github.com/stnolting/riscv-gcc-prebuilt) :
    ```bash
    cd riscv-core

    mkdir rv32i-toolchain
    cd rv32i-toolchain
    wget https://github.com/stnolting/riscv-gcc-prebuilt/releases/download/rv32i-2.0.0/riscv32-unknown-elf.gcc-10.2.0.rv32i.ilp32.newlib.tar.gz
    tar -xzf riscv32-unknown-elf.gcc-10.2.0.rv32i.ilp32.newlib.tar.gz

    export TC=$(pwd)/bin/riscv32-unknown-elf-
    ```

-   **python3** with the needed libraries.
    ```bash
    cd riscv-core

    sudo apt update
    sudo apt install python3 python3-pip

    # python libraries
    pip3 install intelhex
    ```



# useful resources

[RISC-V Assembly Programmer's Manual](https://github.com/riscv/riscv-asm-manual/blob/master/riscv-asm.md)  

[RV32i-opcodes](https://github.com/riscv/riscv-opcodes/blob/master/opcodes-rv32i)  

[Icarus Verilog Manual](https://iverilog.fandom.com/wiki/Main_Page)  

[linker script language](https://ftp.gnu.org/old-gnu/Manuals/ld-2.9.1/html_chapter/ld_3.html)

[Arty A7 Reference Manual](https://digilent.com/reference/programmable-logic/arty-a7/reference-manual)

[RISCV gcc GP (global pointer) register](https://groups.google.com/a/groups.riscv.org/g/sw-dev/c/60IdaZj27dY)

[The GP (global pointer) register](https://gnu-mcu-eclipse.github.io/arch/riscv/programmer/)


# useful commands

```bash
# set your toolchein prefix
TC=/opt/riscv32i/bin/riscv32-unknown-elf-

# compile assembly code  
${TC}as main.S -o build/out.elf

# disassembly code to see instruction hex values
${TC}objdump --disassemble -Mnumeric build/out.elf  

# get a section as hex file  
${TC}objcopy -j.text -O ihex build/out.elf build/out
/opt/riscv32i/bin/riscv32-unknown-elf-objcopy -j.text -O ihex build/out.elf build/out.hex  

# open waveforms generated by iverilog with gtkwave  
gtkwave build/soc_test.vcd &
```