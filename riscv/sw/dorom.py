from intelhex import IntelHex
ih = IntelHex("build/out.hex")

memdata={}

for segment in ih.segments():
    startAddr = segment[0]
    endAddr = segment[1]
    size = endAddr - startAddr

    # 4 byte aligned start and size
    startAddrAligned = startAddr - (startAddr % 4)
    endAddrAligned = endAddr + (4 - (endAddr % 4))
    sizeAligned = endAddrAligned - startAddr

    for i in range(startAddrAligned, endAddrAligned, 4):
        val32bit = 0
        for k in range(0,4):
            addr = i + k
            val32bit += ih[addr] << (8 * k)
        memdata[i // 4] = val32bit

with open('build/rom.v', 'w') as f:
    for cell in memdata:
        line = "mem['h" + str('%04x' % cell) + "] <= 32'h" + str('%08x' % memdata[cell]) + ";\n"
        f.write (line)
        #print(line)

