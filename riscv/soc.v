module soc (
    input clk,
    output [3:0] led
);

    wire bufg;
    BUFG bufgctrl (
        .I(clk),
        .O(bufg)
    );

    wire [31:0] prog_addr, prog_data;
    wire [31:0] data_addr, data_rd, data_wr;
    wire [3:0] data_wr_en;

    reg [31:0] zero32;

    assign data_rd = zero32;

    reg [3:0] led_status;
    assign led_wr = (data_wr_en == 4'h3) && (data_addr == 32'h2000000);

    // intruction memory
    prog_mem ProgMem (prog_addr, prog_data);
    // cpu core
    cpu Cpu (prog_addr, prog_data,
        data_addr, data_rd, data_wr, data_wr_en);
    
    always @(posedge clk) begin
        if (led_wr)
            led_status = 
    end

    initial begin
        zero32 = 0;
        led_status = 0;
    end
    
endmodule

