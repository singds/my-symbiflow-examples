module soc_test;
    
    reg clk;
    wire [4:0] led;

    soc Soc (clk, led);

    integer k;
    initial
    begin
        clk = 0;
        for (k = 0; k < 30; k++)
        begin
            #1;
            $display("led=%h, pc=%h, inst=%h, addr=%h, wren=%h, data=%h, ledwr=%h", led, Soc.Cpu.pc, Soc.Cpu.inst_val, Soc.data_addr, Soc.data_wr_en, Soc.data_wr, Soc.led_wr);
            #1; clk = 1;
            #1; clk = 0;
        end
    end
endmodule