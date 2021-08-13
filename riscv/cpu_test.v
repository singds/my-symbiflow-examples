
module cpu_test;

    reg clk;
    wire [31:0] inst_addr;
    wire [31:0] inst_data;
    
    inst_mem InstMem (inst_addr, inst_data);
    cpu Cpu (clk, inst_addr, inst_data);


    reg [31:0] k; // variable for cycle
    initial begin
        $display("TEST: cpu_test");
        $display("instructions sequence");
        
        clk = 0;
        for (k = 0; k < 2; k++)
        begin
            #1 $display("inst_addr = %h, inst_data = %h", inst_addr, inst_data);
            cycle;
        end

        cycle;
        assert (Cpu.xreg[1] == 32'h34) $display("ok: addi x1, x0, 0x34");

        $finish(0);
    end

    task cycle;
    begin
        #1 clk = 1;
        #1 clk = 0;
    end

endtask

endmodule

module inst_mem
(
    input [31:0] address, // input address
    output [31:0] data // output data
);
    localparam MEM_SIZE = 256;

    reg [31:0] mem [0:MEM_SIZE-1];

    assign data = mem[address[31:2]];

    initial begin
        mem['h0000] <= 32'h00000013; // nop
        mem['h0001] <= 32'h00000013; // nop
        mem['h0002] <= 32'h03400093; // addi x1, x0, 0x34
    end
endmodule

