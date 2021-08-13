module cpu (
    input clk,
    // all instruction are 32bit wide
    output [31:0] inst_addr, // instruction memory address
    input [31:0] inst_val // instruction memory data

/*
    output [31:0] data_addr, // data memory address. <data_addr> ia always available in <data_rd>
    input [31:0] data_rd; // data memory data
    output [31:0] data_wr; // data memory write
    output data_wr, // data memory write.
*/
);
    localparam NUMREG = 32;

    reg [31:0] pc;
    reg [31:0] xreg [0:NUMREG-1];
    
    // these should not become registers in synthesis
    reg [31:0] next_pc;
    reg [31:0] next_xreg [0:NUMREG-1];
    reg [31:0] k; // loop variable

    wire [6:0] opcode;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [4:0] rs1;
    wire [11:0] imm;

    // instruction decode
    assign inst_addr = pc; // pc defines the instruction to fetch
    assign opcode = inst_val[6:0];
    assign rd = inst_val[11:7];
    assign funct3 = inst_val[14:12];
    assign rs1 = inst_val[19:15];
    assign imm = inst_val[31:20];


    parameter OP_IMM = 7'h13;

    parameter FUNC3_ADDI = 4'h0;


    // next state combinational logic
    always @* begin
        next_pc = pc + 4;
        for (k = 0; k < NUMREG; k++)
            next_xreg[k] = xreg[k];

        case (opcode)

            OP_IMM: begin
                case (funct3)

                    FUNC3_ADDI: begin
                        // TODO sign extension
                        next_xreg[rs1] = xreg[rs1] +  imm; // {20{imm[11]}, imm[12:0]};
                    end
                endcase
            end
        endcase

        // x0 must always be 0
        xreg[0] = 32'h0;
    end

    always @(posedge clk) begin
        // move to the next state
        for (k = 0; k < NUMREG; k++)
            xreg[k] = next_xreg[k];
        pc = next_pc;
    end

    initial begin
        pc = 0;
        xreg[0] = 32'h0;
    end
    
endmodule