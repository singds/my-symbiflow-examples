module soc (
    input clk,
    output reg [3:0] led
);
    wire [31:0] prog_addr, prog_data;
    wire [31:0] data_addr, data_wr;
    wire [3:0] data_wr_en;

    wire [31:0] data_rd_ram;
    wire [31:0] data_rd_rom;

    localparam RAMSIZE = 256;
    localparam ROMSIZE = 256;

    // rom start from address 0x00000000
    // ram start from address 0x10000000

    // true when address is pointing to ram memory
    wire sel_ram = (data_addr >= 32'h10000000) && (data_addr < (32'h10000000 + RAMSIZE));
    wire sel_rom = (data_addr >= 32'h00000000) && (data_addr < (32'h00000000 + RAMSIZE));
    wire sel_led = (data_addr == 32'h20000000);

    wire [3:0] data_wr_en_ram = sel_ram ? data_wr_en : 0;

    wire [31:0] data_rd =
        sel_ram ? data_rd_ram :
        sel_rom ? data_rd_rom :
        sel_led ? {28'h0, led} :
        0;

    ram_memory #(RAMSIZE) Ram (
        .clk(clk),
        .wen(data_wr_en_ram),
        .addr(data_addr[21:0]),
        .wdata(data_wr),
        .rdata(data_rd_ram)
        );

    rom_memory #(ROMSIZE) Rom (
        .address(prog_addr),
        .data(prog_data),
        .addressB(data_addr),
        .dataB(data_rd_rom)
        );

    cpu Cpu (
        .clk(clk),
        .inst_addr(prog_addr),
        .inst_val(prog_data),
        .data_addr(data_addr),
        .data_rd(data_rd),
        .data_wr(data_wr),
        .data_wr_en(data_wr_en)
        );
    
    // led peripheral
    wire led_wr = (data_wr_en == 4'b1111) && sel_led;
    always @(posedge clk) begin
        if (led_wr)
            led = data_wr[3:0];
    end

    initial begin
        led = 0;
    end
    
endmodule
