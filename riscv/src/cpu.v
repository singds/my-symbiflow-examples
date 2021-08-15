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
    reg [4:0] status;
    
    // these should not become registers in synthesis
    reg [31:0] next_pc;
    reg [31:0] next_xreg [0:NUMREG-1];
    reg [4:0] next_status;
    reg [31:0] k; // loop variable

    // instruction decode
    assign inst_addr = pc; // pc defines the instruction to fetch
    wire [6:0] opcode = inst_val[6:0];
    wire [4:0] rd = inst_val[11:7];
    wire [2:0] funct3 = inst_val[14:12];
    wire [4:0] rs1 = inst_val[19:15];
    wire [4:0] rs2 = inst_val[24:20];

    wire [11:0] immI = inst_val[31:20];
    wire [31:0] immI32Signed = {{20{immI[11]}}, immI};
    wire [31:0] immU = {inst_val[31:12], 12'h0};
    wire [11:0] immS = {inst_val[31:25], inst_val[11:7]};
    wire [20:0] immJ = {inst_val[31], inst_val[19:12], inst_val[20], inst_val[30:21], 1'b0}; 
    wire [12:0] immB = {inst_val[31], inst_val[7], inst_val[30:25], inst_val[11:8], 1'h0};
    
    wire [31:0] OpStoreAddr = xreg[rs1] + {{20{immS[11]}}, immS};
    wire [31:0] OpLoadAddr = xreg[rs1] + {{20{immI[11]}}, immI};
    wire [31:0] OpBranchAddr = pc + {{19{immB[12]}}, immB};

    parameter OP_IMM = 7'h13;
    parameter OP_LUI = 7'h37;
    parameter OP_AUIPC = 7'h17;
    parameter OP_STORE = 7'h23;
    parameter OP_JAL = 7'h6f;
    parameter OP_LOAD = 7'h03;
    parameter OP_JALR = 7'h67;
    parameter OP_BRANCH = 7'h63;
    parameter OP_OP = 7'h33;

    parameter FUNC3_ADD = 4'h0;
    parameter FUNC3_SUB = 4'h0;
    parameter FUNC3_SLL = 4'h1;
    parameter FUNC3_SRL = 4'h5;
    parameter FUNC3_SRA = 4'h5;
    parameter FUNC3_AND = 4'h7;
    parameter FUNC3_OR = 4'h6;
    parameter FUNC3_XOR = 4'h4;

    parameter FUNC3_ADDI = 4'h0;
    parameter FUNC3_SLTI = 4'h2;
    parameter FUNC3_SLTIU = 4'h3;
    parameter FUNC3_XORI = 4'h4;
    parameter FUNC3_ORI = 4'h6;
    parameter FUNC3_ANDI = 4'h7;
    parameter FUNC3_SLLI = 4'h1;
    parameter FUNC3_SRLI = 4'h5;
    parameter FUNC3_SRAI = 4'h5;

    parameter FUNC3_BEQ = 4'h0;
    parameter FUNC3_BNE = 4'h1;
    parameter FUNC3_BLT = 4'h4;
    parameter FUNC3_BGE = 4'h5;
    parameter FUNC3_BLTU = 4'h6;
    parameter FUNC3_BGEU = 4'h7;

    // next state combinational logic
    always @* begin
        for (k = 0; k < NUMREG; k++)
            next_xreg[k] = xreg[k];
        next_status = 0;
        next_pc = pc + 4; // keep advancing as default

        data_addr = 0;
        data_wr = 0;
        data_wr_en = 0;

        case (opcode)

            OP_OP: begin
                case (funct3)
                    FUNC3_ADD: begin // FUNC3_SUB
                        if (inst_val[30] == 1) // FUNC3_SUB
                            next_xreg[rd] = xreg[rs1] - xreg[rs2];
                        else // FUNC3_ADD
                            next_xreg[rd] = xreg[rs1] + xreg[rs2];
                    end
                    FUNC3_SLL: begin
                        next_xreg[rd] = xreg[rs1] << xreg[rs2][4:0];
                    end
                    FUNC3_SRL: begin // FUNC3_SRA
                        if (inst_val[30] == 1) // FUNC3_SRA
                            next_xreg[rd] = $signed(xreg[rs1]) >>> xreg[rs2][4:0];
                        else
                            next_xreg[rd] = xreg[rs1] >> xreg[rs2][4:0];
                    end
                    FUNC3_AND: begin
                        next_xreg[rd] = xreg[rs1] & xreg[rs2];
                    end
                    FUNC3_OR: begin
                        next_xreg[rd] = xreg[rs1] | xreg[rs2];
                    end
                    FUNC3_XOR: begin
                        next_xreg[rd] = xreg[rs1] ^ xreg[rs2];
                    end
                endcase
            end

            OP_BRANCH: begin
                case (funct3)
                    FUNC3_BEQ: begin
                        if (xreg[rs1] == xreg[rs2])
                            next_pc = OpBranchAddr;
                    end
                    FUNC3_BNE: begin
                        if (xreg[rs1] != xreg[rs2])
                            next_pc = OpBranchAddr;
                    end
                    FUNC3_BLT: begin
                        if ($signed(xreg[rs1]) < $signed(xreg[rs2]))
                            next_pc = OpBranchAddr;
                    end
                    FUNC3_BLTU: begin
                        if (xreg[rs1] < xreg[rs2])
                            next_pc = OpBranchAddr;
                    end
                    FUNC3_BGE: begin
                        if ($signed(xreg[rs1]) >= $signed(xreg[rs2]))
                            next_pc = OpBranchAddr;
                    end
                    FUNC3_BGEU: begin
                        if (xreg[rs1] >= xreg[rs2])
                            next_pc = OpBranchAddr;
                    end
                endcase
            end

            OP_IMM: begin
                case (funct3)
                    FUNC3_ADDI: begin
                        next_xreg[rd] = xreg[rs1] + immI32Signed;
                    end
                    FUNC3_SLTI: begin
                        next_xreg[rd] = $signed(xreg[rs1]) < $signed(immI32Signed) ? 1 : 0;
                    end
                    FUNC3_SLTIU: begin
                        next_xreg[rd] = xreg[rs1] < immI32Signed ? 1 : 0;
                    end
                    FUNC3_ANDI: begin
                        next_xreg[rd] = xreg[rs1] & immI32Signed;
                    end
                    FUNC3_XORI: begin
                        next_xreg[rd] = xreg[rs1] ^ immI32Signed;
                    end
                    FUNC3_ORI: begin
                        next_xreg[rd] = xreg[rs1] | immI32Signed;
                    end
                    FUNC3_SLLI: begin
                        next_xreg[rd] = xreg[rs1] << immI[4:0];
                    end
                    FUNC3_SRLI: begin // FUNC3_SRAI
                        if (inst_val[30]) // signed shift (FUNC3_SRAI)
                            next_xreg[rd] = $signed(xreg[rs1]) >>> immI[4:0];
                        else // logical shit (FUNC3_SRLI)
                            next_xreg[rd] = xreg[rs1] >> immI[4:0];
                    end
                endcase
            end

            // jal
            OP_JAL: begin
                next_xreg[rd] = pc + 4;
                // The offset is sign-extended and added to the pc to form the jump target address.
                next_pc = pc + {{12{immJ[20]}}, immJ};
            end

            // jalr
            OP_JALR: begin
                next_xreg[rd] = pc + 4;
                // The target address is obtained by adding the sign-extended 12-bit
                // I-immediate to the register rs1, then setting the least-significant
                //bit of the result to zero
                next_pc = xreg[rs1] + {{20{immI[11]}}, immI};
            end

            // load, keep 2 cycles
            OP_LOAD: begin
                case (status)
                    0: begin // one clock to get data from memory
                        data_addr = {OpLoadAddr[31:2], 2'h0};
                        next_status = status + 1;
                        next_pc = pc;
                    end
                    1: begin // one clock to save data in register
                        next_xreg[rd] = data_rd >> {OpLoadAddr[1:0], 3'h0};
                        case (funct3[1:0])
                            0: begin // 1 byte
                                if (!funct3[2]) // singed
                                    next_xreg[rd] = {{24{next_xreg[rd][7]}}, next_xreg[rd][7:0]};
                                else // unsigned
                                    next_xreg[rd] = {24'h0, next_xreg[rd][7:0]};
                            end
                            1: begin // 2 bytes
                                if (!funct3[2]) // signed
                                    next_xreg[rd] = {{24{next_xreg[rd][15]}}, next_xreg[rd][15:0]};
                                else // unsigned
                                    next_xreg[rd] = {24'h0, next_xreg[rd][15:0]};
                            end
                        endcase
                    end
                endcase
            end

            // store
            OP_STORE: begin
                // EEI not support misaligned loads and stores
                data_addr = {OpStoreAddr[31:2], 2'h0};

                data_wr = xreg[rs2] << {OpStoreAddr[1:0], 3'h0};
                if (funct3 == 0)
                    data_wr_en = 4'b0001;
                else if (funct3 == 1)
                    data_wr_en = 4'b0011;
                else if (funct3 == 2)
                    data_wr_en = 4'b1111;
                
                data_wr_en = data_wr_en << OpStoreAddr[1:0];
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

        
        if (next_status == 0)

        // x0 must always be 0
        xreg[0] = 32'h0;
    end



    always @(posedge clk) begin
        // move to the next state
        for (k = 0; k < NUMREG; k++)
            xreg[k] = next_xreg[k];
        pc = next_pc;
        status = next_status;
    end



    initial begin
        pc = 0;
        for (k = 0; k < NUMREG; k++)
            xreg[k] = 32'h0;
        status = 0;
    end
    
endmodule