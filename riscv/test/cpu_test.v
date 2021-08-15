
module cpu_test;

    reg clk;
    wire [31:0] inst_addr; // unused
    reg [31:0] inst_data;

    wire [31:0] data_addr, data_rd, data_wr;
    wire [3:0] data_wr_en;
    
    ram Ram (clk, data_wr_en, data_addr[21:0], data_wr, data_rd);

    cpu Cpu (clk, inst_addr, inst_data,
        data_addr, data_rd, data_wr, data_wr_en);

    reg [31:0] k; // variable for cycle
    reg [31:0] save;
    initial begin
        $dumpfile("cpu_test.vcd");
        $dumpvars(0,cpu_test);

        $display("TEST: cpu_test");
        $display("instructions sequence");

        clk = 0;
        inst_data = 0;

        testNop ( );
        testAddi ( );
        testStore ( );
        testLoad ( );
        testJal ( );
        testLittleEndian32bit ( );
        testLittleEndian16bit ( );
        testJalr ( );
        testBeq ( );
        testBne ( );

        $finish(0);
    end

    task clkCycle;
    begin
        #1; clk = 1;
        #1; clk = 0;
    end
    endtask

    task exeInst;
        input [4:0] ncycles; // clock cycles the instruction needs to execute
        input [31:0] instruction; // the instruction
    begin
        inst_data = instruction;
        for (k = 0; k < ncycles; k++)
            clkCycle;
    end
    endtask

    // Test NOP operation
    task testNop;
    begin
        save = Cpu.pc;

        exeInst (1, 32'h00000013); // nop
        assert (Cpu.pc == (save + 4));
        else $display("pc=%h", Cpu.pc);

        $display("ok: nop");
    end
    endtask

    // Test ADDI operation
    task testAddi;
    begin
        exeInst (1, 32'h03400093); // addi x1, x0, 0x34
        assert (Cpu.xreg[1] == 32'h34);

        $display("ok: addi");
    end
    endtask

    // Test STORE operation
    task testStore;
    begin
        
        Cpu.xreg[2] = 32'h00000001;

        // STORE 1 BYTE
        Ram.mem[0] = 32'hffffffff;
        exeInst (1, 32'h00000093); // li      x1,0
        // store x2 in address x1 + 0
        exeInst (1, 32'h00208023); // sb      x2,0(x1)
        assert (Ram.mem[0] == 32'hffffff01);

        Ram.mem[0] = 32'hffffffff;
        exeInst (1, 32'h00100093); // li      x1,1
        exeInst (1, 32'h00208023); // sb      x2,0(x1)
        assert (Ram.mem[0] == 32'hffff01ff);

        Ram.mem[0] = 32'hffffffff;
        exeInst (1, 32'h00200093); // li      x1,2
        exeInst (1, 32'h00208023); // sb      x2,0(x1)
        assert (Ram.mem[0] == 32'hff01ffff);

        Ram.mem[0] = 32'hffffffff;
        exeInst (1, 32'h00300093); // li      x1,3
        exeInst (1, 32'h00208023); // sb      x2,0(x1)
        assert (Ram.mem[0] == 32'h01ffffff);


        // STORE 2 BYTES
        Ram.mem[0] = 32'hffffffff;
        exeInst (1, 32'h00000093); // li      x1,0
        exeInst (1, 32'h00209023); // sh      x2,0(x1)
        assert (Ram.mem[0] == 32'hffff0001);

        Ram.mem[0] = 32'hffffffff;
        exeInst (1, 32'h00200093); // li      x1,2
        exeInst (1, 32'h00209023); // sh      x2,0(x1)
        assert (Ram.mem[0] == 32'h0001ffff);


        // STORE 4 BYTES
        Ram.mem[0] = 32'hffffffff;
        exeInst (1, 32'h00000093); // li      x1,0
        exeInst (1, 32'h0020a023); // sw      x2,0(x1)
        assert (Ram.mem[0] == 32'h00000001);

        $display("ok: store");
    end
    endtask

    task testLoad;
    begin

        Ram.mem[0] = 32'h90A0B0C0;
        // 1 byte load signed
        Cpu.xreg[2] = 0;
        exeInst (2, 32'h00000103); // lb      x2,0(x0)
        assert (Cpu.xreg[2] == 32'hffffffC0);
        
        exeInst (2, 32'h00100103); // lb      x2,1(x0)
        assert (Cpu.xreg[2] == 32'hffffffB0);
        
        exeInst (2, 32'h00200103); // lb      x2,2(x0)
        assert (Cpu.xreg[2] == 32'hffffffA0);

        exeInst (2, 32'h00300103); // lb      x2,3(x0)
        assert (Cpu.xreg[2] == 32'hffffff90);


        Ram.mem[0] = 32'h91A1B1C1;
        // 2 byte load signed
        exeInst (2, 32'h00001103); // lb      x2,3(x0)
        assert (Cpu.xreg[2] == 32'hffffB1C1);

        exeInst (2, 32'h00201103); // lb      x2,3(x0)
        assert (Cpu.xreg[2] == 32'hffff91A1);


        Ram.mem[0] = 32'h90A0B0C0;
        // 1 byte load unsigned
        Cpu.xreg[2] = 0;
        exeInst (2, 32'h00004103); // lbu      x2,0(x0)
        assert (Cpu.xreg[2] == 32'h000000C0);
        
        exeInst (2, 32'h00104103); // lbu      x2,1(x0)
        assert (Cpu.xreg[2] == 32'h000000B0);
        
        exeInst (2, 32'h00204103); // lbu      x2,2(x0)
        assert (Cpu.xreg[2] == 32'h000000A0);

        exeInst (2, 32'h00304103); // lbu      x2,3(x0)
        assert (Cpu.xreg[2] == 32'h00000090);


        Ram.mem[0] = 32'h91A1B1C1;
        // 2 byte load unsigned
        exeInst (2, 32'h00005103); // lhu      x2,3(x0)
        assert (Cpu.xreg[2] == 32'h0000B1C1);

        exeInst (2, 32'h00205103); // lhu      x2,3(x0)
        assert (Cpu.xreg[2] == 32'h000091A1);


        Ram.mem[0] = 32'h92A2B2C2;
        // 4 byte load
        exeInst (2, 32'h00002103); // lw      x2,0(x0)
        assert (Cpu.xreg[2] == 32'h92A2B2C2);

        $display("ok: load");
    end
    endtask

    task testLittleEndian32bit;
    begin
        // LSByte must appear before MSByte in memory

        // value to be stored
        Cpu.xreg[2] = 32'h01020304; // x2 = 1
        Cpu.xreg[1] = 32'h00000000; // x1 = 0

        // STORE 4 BYTES
        exeInst (1, 32'h0020a023); // sw      x2,0(x1)


        // read single bytes
        // lowest byte
        exeInst (2, 32'h00004103); // lbu      x2,0(x0)
        assert (Cpu.xreg[2] == 32'h00000004);
        
        exeInst (2, 32'h00104103); // lbu      x2,1(x0)
        assert (Cpu.xreg[2] == 32'h00000003);
        
        exeInst (2, 32'h00204103); // lbu      x2,2(x0)
        assert (Cpu.xreg[2] == 32'h00000002);
        // highest byte
        exeInst (2, 32'h00304103); // lbu      x2,3(x0)
        assert (Cpu.xreg[2] == 32'h00000001);


        // read half words (2 byte)
        // lowest half
        exeInst (2, 32'h00005103); // lhu      x2,3(x0)
        assert (Cpu.xreg[2] == 32'h00000304);

        // highest half
        exeInst (2, 32'h00205103); // lhu      x2,3(x0)
        assert (Cpu.xreg[2] == 32'h00000102);


        // read word (4 byte)
        exeInst (2, 32'h00002103); // lw      x2,0(x0)
        assert (Cpu.xreg[2] == 32'h01020304);

        $display("ok: little endian 32bit");
    end
    endtask

    task testLittleEndian16bit;
    begin
        // LSByte must appear before MSByte in memory

        // value to be stored
        Cpu.xreg[2] = 32'h00000102; // x2 = 1
        Cpu.xreg[1] = 32'h00000000; // x1 = 0

        // STORE 2 BYTES
        exeInst (1, 32'h00209023); // sh      x2,0(x1)

        // read single bytes
        // lowest byte
        exeInst (2, 32'h00004103); // lbu      x2,0(x0)
        assert (Cpu.xreg[2] == 32'h00000002);
        // highest byte
        exeInst (2, 32'h00104103); // lbu      x2,1(x0)
        assert (Cpu.xreg[2] == 32'h00000001);


        // read half word (2 byte)
        exeInst (2, 32'h00005103); // lhu      x2,3(x0)
        assert (Cpu.xreg[2] == 32'h00000102);

        $display("ok: little endian 16bit");
    end
    endtask

    task testJal;
    begin
        exeInst (1, 32'h00000013); // nop
        exeInst (1, 32'h00000013); // nop
        exeInst (1, 32'h00000013); // nop
        exeInst (1, 32'h00000013); // nop
        exeInst (1, 32'h00000013); // nop
        save = Cpu.pc;
        exeInst (1, 32'hfedff06f); // jal pc-20
        assert (Cpu.pc == (save - 20))
        else $display("pc=%h, save = %h", Cpu.pc, save);

        $display("ok: jal");
    end
    endtask

    task testJalr;
    begin
        Cpu.xreg[2] = 32'h12345678;
        Cpu.pc = 32'h90909090;
        exeInst (1, 32'h000101e7); // jalr    x3,x2
        assert (Cpu.xreg[3] == (32'h90909090 + 4));
        assert (Cpu.pc == 32'h12345678);

        $display("ok: jalr");
    end 
    endtask

    task testBeq;
    begin
        // no breanch
        Cpu.pc = 0;
        Cpu.xreg[4] = 0;
        Cpu.xreg[5] = 1;
        exeInst (1, 32'h00520863); // beq     x4,x5,pc+0x10
        assert (Cpu.pc == 32'h4)

        // brench
        Cpu.pc = 0;
        Cpu.xreg[4] = 1;
        Cpu.xreg[5] = 1;
        exeInst (1, 32'h00520863); // beq     x4,x5,pc+0x10
        assert (Cpu.pc == 32'h10);

        $display("ok: beq");
    end
    endtask

    task testBne;
    begin
        // no breanch
        Cpu.pc = 0;
        Cpu.xreg[4] = 1;
        Cpu.xreg[5] = 1;
        exeInst (1, 32'h00521863); // bne     x4,x5,pc+0x10
        assert (Cpu.pc == 32'h4)

        // brench
        Cpu.pc = 0;
        Cpu.xreg[4] = 1;
        Cpu.xreg[5] = 0;
        exeInst (1, 32'h00521863); // bne     x4,x5,pc+0x10
        assert (Cpu.pc == 32'h10);

        $display("ok: bne");
    end
    endtask

endmodule

// ram start at address 0
module ram #(
	parameter integer WORDS = 256
) (
	input clk,
	input [3:0] wen,
	input [21:0] addr,
	input [31:0] wdata,
	output reg [31:0] rdata
);
	reg [31:0] mem [0:WORDS-1];

	always @(posedge clk) begin
		rdata <= mem[addr];
		if (wen[0]) mem[addr][ 7: 0] <= wdata[ 7: 0];
		if (wen[1]) mem[addr][15: 8] <= wdata[15: 8];
		if (wen[2]) mem[addr][23:16] <= wdata[23:16];
		if (wen[3]) mem[addr][31:24] <= wdata[31:24];
	end
endmodule
