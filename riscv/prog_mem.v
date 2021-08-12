

module prog_mem
(
    input [31:0] address, // input address
    output [31:0] data // output data
);
    localparam MEM_SIZE = 256;

    reg [31:0] mem [0:MEM_SIZE-1];

    assign data = mem[address];

    initial begin
        mem['h0000] <= 32'h00000001;
        mem['h0001] <= 32'h00000002;
        mem['h0002] <= 32'h00000003;
        mem['h0003] <= 32'hf0000004;
    end
endmodule