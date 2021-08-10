module top (
    input clk,
    output [3:0] led
);

    wire bufg;
    BUFG bufgctrl (
        .I(clk),
        .O(bufg)
    );

    pwm #(10,100) mPwm1(bufg, led[0]);
    pwm #(30,100) mPwm2(bufg, led[1]);
    pwm #(60,100) mPwm3(bufg, led[2]);
    pwm #(90,100) mPwm4(bufg, led[3]);
endmodule
