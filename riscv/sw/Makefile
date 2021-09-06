TC ?= /opt/riscv32i/bin/riscv32-unknown-elf-
# -mno-relax option disables linker relaxation. See linker script for more info.
GCCFLAGS = -nostdlib -mno-relax
BUILDDIR = build

compile: ${BUILDDIR} startup.s main.c
# -save-temps
#   Store the usual "temporary" intermediate files permanently.
#   Compiling foo.c with -c -save-temps produces files foo.i and foo.s, as well
#   as foo.o.
	cd ${BUILDDIR} && ${TC}gcc ${GCCFLAGS} -O0 -save-temps -T../linker-script.ld -Wl,-Map=final.map ../main.c ../startup.s -o out.elf
# create hex file with rom code and data
	cd ${BUILDDIR} && ${TC}objcopy -O ihex out.elf out.hex
# convert hex file in verilog memory array
	python3 gen-rom.py build/out.hex build/rom.v

${BUILDDIR}:
	mkdir -p ${BUILDDIR}

