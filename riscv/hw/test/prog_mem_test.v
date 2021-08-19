
module prog_mem_test;

    reg [31:0] address;
    wire [31:0] data;
    
    // uut = unit under test
    prog_mem uut (address, data);

    reg [31:0] k; // variable for cycle
    initial begin
        $dumpfile("prog_mem_test.vcd");
        $dumpvars(0,prog_mem_test);

        $display("TEST: prog_mem_test");
        $display("print first 4 memory addresses");
        
        for (k = 0; k < 4; k++)
        begin
            address = k;
            #1;
            $display("addr[%d] = %h", k, data);
        end

        $finish;
    end

endmodule