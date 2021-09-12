mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(patsubst %/,%,$(dir $(mkfile_path)))
TOP := top
SRCDIR = ${current_dir}
VERILOG := ${SRCDIR}/top.v \
	${SRCDIR}/soc.v \
	${SRCDIR}/cpu.v \
	${SRCDIR}/memory.v
DEVICE := xc7a50t_test
BITSTREAM_DEVICE := artix7
BUILDDIR := build
PARTNAME := xc7a35tcsg324-1
XDC := ${current_dir}/arty.xdc
TARGET=arty_35
BOARD_BUILDDIR := ${BUILDDIR}/arty_35

IVERILOG := iverilog -g2012
IVERILOGVVP := vvp
TESTDIR = ${SRCDIR}/test

.DELETE_ON_ERROR:


# every time you call this targets they are executed
.PHONY: test clean


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

# load the bitstream in the fpga board
run:
	cd ${BOARD_BUILDDIR} && sudo openocd -f ${INSTALL_DIR}/${FPGA_FAM}/conda/envs/${FPGA_FAM}/share/openocd/scripts/board/digilent_arty.cfg -c "init; pld load 0 top.bit; exit"

# compile and run testbenches with Icarus Verilog
test: ${BUILDDIR}
	cd ${BUILDDIR} && ${IVERILOG} ${TESTDIR}/cpu_test.v ${SRCDIR}/cpu.v ${SRCDIR}/memory.v -o cpu_test
	cd ${BUILDDIR} && ${IVERILOG} ${TESTDIR}/soc_test.v ${SRCDIR}/soc.v ${SRCDIR}/cpu.v ${SRCDIR}/memory.v -o soc_test

	cd ${BUILDDIR} && ${IVERILOGVVP} cpu_test
	cd ${BUILDDIR} && ${IVERILOGVVP} soc_test
