module cpu (
    input clk,

    // all instruction are 32bit wide
    output [31:0] inst_addr, // instruction memory address
    input [31:0] inst_val, // instruction memory data

    // these registers should not become memory elements in sythesis
    // bacause they are always assigned in the always block
    // tha always block represent only combinational logic
    output reg [31:0] data_addr, // data memory address. <data_addr> ia always available in <data_rd>
    input [31:0] data_rd, // data memory read
    output reg [31:0] data_wr, // data memory write
    output reg [3:0] data_wr_en // data memory write.
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
    wire [4:0] rs2;
    wire [11:0] immI;
    wire [31:0] immU;
    wire [11:0] immS;
    wire [20:0] immJ;

    // instruction decode
    assign inst_addr = pc; // pc defines the instruction to fetch
    assign opcode = inst_val[6:0];
    assign rd = inst_val[11:7];
    assign funct3 = inst_val[14:12];
    assign rs1 = inst_val[19:15];
    assign rs2 = inst_val[24:20];

    assign immI = inst_val[31:20];
    assign immU = {inst_val[31:12], 12'h0};
    assign immS = {inst_val[31:25], inst_val[11:7]};
    assign immJ = {inst_val[31], inst_val[19:12], inst_val[20], inst_val[30:21], 1'b0}; 


    parameter OP_IMM = 7'h13;
    parameter OP_LUI = 7'h37;
    parameter OP_AUIPC = 7'h17;
    parameter OP_STORE = 7'h23;
    parameter OP_JAL = 7'h6f;

    parameter FUNC3_ADDI = 4'h0;


    // next state combinational logic
    always @* begin
        next_pc = pc + 4;
        for (k = 0; k < NUMREG; k++)
            next_xreg[k] = xreg[k];
        data_addr = 0;
        data_wr = 0;
        data_wr_en = 0;

        case (opcode)

            OP_IMM: begin
                case (funct3)

                    FUNC3_ADDI: begin
                        // TODO sign extension
                        next_xreg[rd] = xreg[rs1] + {{20{immI[11]}}, immI};
                    end
                endcase
            end

            // jal
            OP_JAL: begin
                next_xreg[rd] = pc + 4;
                // The offset is sign-extended and added to the pc to form the jump target address.
                next_pc = pc + {{12{immJ[20]}}, immJ};
            end

            // store
            OP_STORE: begin
                data_addr = xreg[rs1] + {{20{immS[11]}}, immS};
                data_wr = xreg[rs2];
                if (funct3 == 0)
                    data_wr_en = 4'b0001;
                else if (funct3 == 1)
                    data_wr_en = 4'b0011;
                else if (funct3 == 2)
                    data_wr_en = 4'b1111;
            end

            // load upper immediate
            OP_LUI: begin 
                next_xreg[rd] = immU;
            end

            // load upper immediate to pc
            OP_AUIPC: begin
                next_xreg[rd] = pc + immU;
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
        for (k = 0; k < NUMREG; k++)
            xreg[k] = 32'h0;
    end
    
endmodule