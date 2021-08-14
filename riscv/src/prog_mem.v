
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
        mem['h0000] <= 32'h00000013;
        mem['h0001] <= 32'h200000b7;
        mem['h0002] <= 32'h00100113;
        mem['h0003] <= 32'h0020a023;
        mem['h0004] <= 32'h00000113;
        mem['h0005] <= 32'h0020a023;
        mem['h0006] <= 32'hfedff06f;
    end
endmodule