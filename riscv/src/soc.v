module soc (
    input clk,
    output reg [3:0] led
);
    wire [31:0] prog_addr, prog_data;
    wire [31:0] data_addr, data_rd, data_wr;
    wire [3:0] data_wr_en;

    reg [31:0] zero32;

    assign data_rd = zero32;

    assign led_wr = (data_wr_en == 4'b1111) && (data_addr == 32'h20000000);

    // intruction memory
    prog_mem ProgMem (prog_addr, prog_data);
    // cpu core
    cpu Cpu (clk, prog_addr, prog_data,
        data_addr, data_rd, data_wr, data_wr_en);
    
    always @(posedge clk) begin
        if (led_wr)
            led = data_wr[3:0];
    end

    initial begin
        zero32 = 0;
        led = 0;
    end
    
endmodule

