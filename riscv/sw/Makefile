TC=/opt/riscv32i/bin/riscv32-unknown-elf-
GCCFLAGS=-nostdlib

BUILDDIR=build


compile: ${BUILDDIR} startup.s main.c
	cd ${BUILDDIR} && ${TC}gcc ${GCCFLAGS} -T../linker-script.ld -Wl,-Map=final.map ../main.c ../startup.s -o out.elf
# produce hex file with rom code and data
	cd ${BUILDDIR} && ${TC}objcopy -O ihex out.elf out.hex

only_compile: ${BUILDDIR} startup.s main.c
	cd ${BUILDDIR} && ${TC}gcc ${GCCFLAGS} -S ../main.c

only_assemble: only_compile
	cd ${BUILDDIR} && ${TC}as ../startup.s main.s -o as.elf

link: assemble
	cd ${BUILDDIR} && ${TC}ld -Map=final.map -T../linker-script.ld as.elf -o out.elf

${BUILDDIR}:
	mkdir -p ${BUILDDIR}

