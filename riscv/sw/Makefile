TC=/opt/riscv32i/bin/riscv32-unknown-elf-
GCCFLAGS=-nostdlib
BUILDDIR=build

compile: ${BUILDDIR} startup.s main.c
	cd ${BUILDDIR} && ${TC}gcc ${GCCFLAGS} -O0 -T../linker-script.ld -Wl,-Map=final.map ../main.c ../startup.s -o out.elf
# create hex file with rom code and data
	cd ${BUILDDIR} && ${TC}objcopy -O ihex out.elf out.hex
# convert hex file in verilog memory array
	python3 gen-rom.py build/out.hex build/rom.v

compile_only: ${BUILDDIR} startup.s main.c
	cd ${BUILDDIR} && ${TC}gcc ${GCCFLAGS} -S ../main.c

assemble_only: only_compile
	cd ${BUILDDIR} && ${TC}as ../startup.s main.s -o as.elf

${BUILDDIR}:
	mkdir -p ${BUILDDIR}

