import sys

arglen = len(sys.argv)
if (arglen != 3):
    print("error: you must provide source .hex file and .v destionation file in this order")
    print(str(arglen) + " args detected")
    exit(1)

# arg 0 is python script name
# first command line arg is the hex source file
# second command line arg is the verilog file to be created
srcFile = sys.argv[1]
dstFile = sys.argv[2]

# use intelhex library to read intelhex file format
from intelhex import IntelHex
ih = IntelHex(srcFile)

# memory data as a 4bytes array
memdata={}

for segment in ih.segments():
    startAddr = segment[0]
    endAddr = segment[1]
    size = endAddr - startAddr

    # 4 byte aligned start and size
    startAddrAligned = startAddr - (startAddr % 4)
    endAddrAligned = endAddr + (4 - (endAddr % 4))
    sizeAligned = endAddrAligned - startAddr

    # build a 4bytes data array form 1byte data array
    for i in range(startAddrAligned, endAddrAligned, 4):
        val32bit = 0
        for k in range(0,4):
            addr = i + k
            val32bit += ih[addr] << (8 * k)
        memdata[i // 4] = val32bit

# write rom file
with open(dstFile, 'w') as f:
    for cell in memdata:
        line = "mem['h" + str('%04x' % cell) + "] <= 32'h" + str('%08x' % memdata[cell]) + ";\n"
        f.write (line)
        # print(line)

