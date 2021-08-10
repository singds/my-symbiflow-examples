module testbench;
    reg clk;
    reg [31:0] c;
    wire pwm1;

    pwm #(2,4) mPwm(clk, pwm1);
    

    initial
    begin
        $monitor("%d %b", c, pwm1);

        for(c=0; c < 20; c++)
        begin
            clk = 1;
            #1;
            clk = 0;
            #1;
        end
        $finish;
    end
endmodule