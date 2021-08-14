module top (
    input clk,
    output [3:0] led
);

    wire bufg;
    BUFG bufgctrl (
        .I(clk),
        .O(bufg)
    );

    wire [3:0] socled;
    assign led = {2'h0, 1'h1, socled[0]};

    soc Soc (bufg, socled[3:0]);
endmodule