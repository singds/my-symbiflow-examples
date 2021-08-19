module soc_test;
    
    reg clk;
    wire [3:0] led;

    soc Soc (clk, led);

    integer k;
    initial
    begin
        $display("TEST: soc_test");
        $display("simulate some clock cycles");

        $dumpfile("soc_test.vcd");
        $dumpvars(0,soc_test);

        //$dumpvars(1, Soc.Cpu.xreg[2]);
        for (k = 0; k < 32; k++)
             $dumpvars(1, Soc.Cpu.xreg[k]);

        clk = 0;
        for (k = 0; k < 200; k++)
        begin
            #1; clk = 1;
            #1; clk = 0;
        end
    end
endmodule