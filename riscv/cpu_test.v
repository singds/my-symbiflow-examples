
module cpu_test;

    reg clk;
    wire [31:0] inst_addr; // unused
    reg [31:0] inst_data;
    
    cpu Cpu (clk, inst_addr, inst_data); 

    reg [31:0] k; // variable for cycle
    initial begin
        $display("TEST: cpu_test");
        $display("instructions sequence");
        
        clk = 0;
        inst_data = 0;

        testNop ( );
        testAddi ( );

        $finish(0);
    end

    task clkCycle;
    begin
        #1 clk = 1;
        #1 clk = 0;
    end
    endtask

    task exeInst;
        input [31:0] instruction;
    begin
        inst_data = instruction;
        clkCycle;
    end
    endtask

    // Test NOP operation
    task testNop;
    begin
        assert (Cpu.pc == 32'h0);

        exeInst (32'h00000013); // nop
        assert (Cpu.pc == 32'h4);
        else $display("pc=%h", Cpu.pc);

        $display("ok: nop");
    end
    endtask

    // Test ADDI operation
    task testAddi;
    begin
        exeInst (32'h03400093); // addi x1, x0, 0x34
        assert (Cpu.xreg[1] == 32'h34);

        $display("ok: addi");
    end
    endtask

endmodule

