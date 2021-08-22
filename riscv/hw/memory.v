
module rom_memory #(
	parameter integer WORDS = 256
) (
    input [31:0] address, // input address
    output [31:0] data, // output data
	input [31:0] addressB, // second port input address
	output [31:0] dataB // second port output data
);
    reg [31:0] mem [0:WORDS-1];

    // only 4 byte aligned accesses
    assign data = mem[address[31:2]];
	assign dataB = mem[addressB[31:2]];

    initial begin

// you decide the program you want to run uncommenting the right line of the following

// prebuild rom examples
        //`include "../sw/rom/led-blink.v"
        //`include "../sw/rom/led-blink-fast.v"

// you rom compiled from sw/main.c
        `include "../sw/build/rom.v"

    end
endmodule



module ram_memory #(
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
