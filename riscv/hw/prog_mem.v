
// rom program memory
module prog_mem
(
    input [31:0] address, // input address
    output [31:0] data // output data
);
    localparam MEM_SIZE = 256;

    reg [31:0] mem [0:MEM_SIZE-1];

    // only 4 byte aligned accesses
    assign data = mem[address[31:2]];

    initial begin
        //`include "sw/rom/led-blink.v"
        //`include "sw/rom/led-blink-fast.v"

        `include "sw/build/rom.v"
    end
endmodule