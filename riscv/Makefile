
BUILDDIR := build
IVERILOG := iverilog

${BUILDDIR}:
	mkdir -p ${BUILDDIR}

test: ${BUILDDIR}
	${IVERILOG} prog_mem_test.v prog_mem.v -o ${BUILDDIR}/prog_mem_test
	${IVERILOG} cpu_test.v cpu.v -o ${BUILDDIR}/cpu_test

	${BUILDDIR}/prog_mem_test
	${BUILDDIR}/cpu_test
