mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(patsubst %/,%,$(dir $(mkfile_path)))
TOP := top
SRCDIR = ${current_dir}/src
VERILOG := ${SRCDIR}/top.v \
	${SRCDIR}/soc.v \
	${SRCDIR}/cpu.v \
	${SRCDIR}/prog_mem.v
DEVICE := xc7a50t_test
BITSTREAM_DEVICE := artix7
BUILDDIR := build
PARTNAME := xc7a35tcsg324-1
XDC := ${current_dir}/arty.xdc
TARGET=arty_35
BOARD_BUILDDIR := ${BUILDDIR}/arty_35

IVERILOG := iverilog -g2012
IVERILOGVVP := vvp
TESTDIR = ${current_dir}/test

.DELETE_ON_ERROR:


all: ${BOARD_BUILDDIR}/${TOP}.bit

${BUILDDIR}:
	mkdir -p ${BUILDDIR}

${BOARD_BUILDDIR}:
	mkdir -p ${BOARD_BUILDDIR}

${BOARD_BUILDDIR}/${TOP}.eblif: | ${BOARD_BUILDDIR}
	cd ${BOARD_BUILDDIR} && symbiflow_synth -t ${TOP} -v ${VERILOG} -d ${BITSTREAM_DEVICE} -p ${PARTNAME} -x ${XDC} 2>&1 > /dev/null

${BOARD_BUILDDIR}/${TOP}.net: ${BOARD_BUILDDIR}/${TOP}.eblif
	cd ${BOARD_BUILDDIR} && symbiflow_pack -e ${TOP}.eblif -d ${DEVICE} 2>&1 > /dev/null

${BOARD_BUILDDIR}/${TOP}.place: ${BOARD_BUILDDIR}/${TOP}.net
	cd ${BOARD_BUILDDIR} && symbiflow_place -e ${TOP}.eblif -d ${DEVICE} -n ${TOP}.net -P ${PARTNAME} 2>&1 > /dev/null

${BOARD_BUILDDIR}/${TOP}.route: ${BOARD_BUILDDIR}/${TOP}.place
	cd ${BOARD_BUILDDIR} && symbiflow_route -e ${TOP}.eblif -d ${DEVICE} 2>&1 > /dev/null

${BOARD_BUILDDIR}/${TOP}.fasm: ${BOARD_BUILDDIR}/${TOP}.route
	cd ${BOARD_BUILDDIR} && symbiflow_write_fasm -e ${TOP}.eblif -d ${DEVICE}

${BOARD_BUILDDIR}/${TOP}.bit: ${BOARD_BUILDDIR}/${TOP}.fasm
	cd ${BOARD_BUILDDIR} && symbiflow_write_bitstream -d ${BITSTREAM_DEVICE} -f ${TOP}.fasm -p ${PARTNAME} -b ${TOP}.bit

clean:
	rm -rf ${BUILDDIR}

# run the example in the fpga board
run:
	cd ${BOARD_BUILDDIR} && sudo openocd -f ${INSTALL_DIR}/${FPGA_FAM}/conda/envs/${FPGA_FAM}/share/openocd/scripts/board/digilent_arty.cfg -c "init; pld load 0 top.bit; exit"

.PHONY: test
test: ${BUILDDIR}
	${IVERILOG} ${TESTDIR}/prog_mem_test.v ${SRCDIR}/prog_mem.v -o ${BUILDDIR}/prog_mem_test
	${IVERILOG} ${TESTDIR}/cpu_test.v ${SRCDIR}/cpu.v -o ${BUILDDIR}/cpu_test
	${IVERILOG} ${TESTDIR}/soc_test.v ${SRCDIR}/soc.v ${SRCDIR}/cpu.v ${SRCDIR}/prog_mem.v -o ${BUILDDIR}/soc_test

	cd ${BUILDDIR} && ${IVERILOGVVP} prog_mem_test
	cd ${BUILDDIR} && ${IVERILOGVVP} cpu_test
	cd ${BUILDDIR} && ${IVERILOGVVP} soc_test
