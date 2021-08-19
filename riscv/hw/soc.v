module soc (
    input clk,
    output reg [3:0] led
);
    wire [31:0] prog_addr, prog_data;
    wire [31:0] data_addr, data_rd, data_wr;
    wire [3:0] data_wr_en;

    assign led_wr = (data_wr_en == 4'b1111) && (data_addr == 32'h20000000);

    // ram memory
    ram Ram (clk, data_wr_en, data_addr[21:0], data_wr, data_rd);
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
        led = 0;
    end
    
endmodule

// ram start at address 0
module ram #(
	parameter integer WORDS = 256
) (
	input clk,
	input [3:0] wen,
	input [21:0] addr,
	input [31:0] wdata,
	output reg [31:0] rdata
);
	reg [31:0] mem [0:WORDS-1];

	always @(posedge clk) begin
		rdata <= mem[addr];
		if (wen[0]) mem[addr][ 7: 0] <= wdata[ 7: 0];
		if (wen[1]) mem[addr][15: 8] <= wdata[15: 8];
		if (wen[2]) mem[addr][23:16] <= wdata[23:16];
		if (wen[3]) mem[addr][31:24] <= wdata[31:24];
	end

endmodule
