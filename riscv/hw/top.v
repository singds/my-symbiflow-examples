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
    assign led = {2'b11, socled[1:0]};

    soc Soc (bufg, socled[3:0]);
endmodule