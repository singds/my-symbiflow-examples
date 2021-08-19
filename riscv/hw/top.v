module top (
    input clk,
    output [3:0] led
);

    wire bufg;
    BUFG bufgctrl (
        .I(clk),
        .O(bufg)
    );

    soc Soc (bufg, led);
endmodule