module soc (
    input in_clk,
    output reg [3:0] led
);
    wire [31:0] prog_addr, prog_data;
    wire [31:0] data_addr, data_wr;
    wire [3:0] data_wr_en;

    wire [31:0] data_rd_ram;
    wire [31:0] data_rd_rom;

    localparam RAMSIZE = 256;
    localparam ROMSIZE = 256;


    wire clk;
    // lower the 100 Mhz frequency
    clk_divider divider(in_clk, clk);

    // rom start from address 0x00000000
    // ram start from address 0x10000000
    localparam ROM_START_ADDR = 32'h00000000;
    localparam RAM_START_ADDR = 32'h10000000;
    localparam LED_REG_ADDR = 32'h20000000;
    
    // ADDRESS DECODER
    // true when address is pointing to ram memory
    wire sel_ram = (data_addr >= RAM_START_ADDR) && (data_addr < (RAM_START_ADDR + RAMSIZE));
    wire sel_rom = (data_addr >= ROM_START_ADDR) && (data_addr < (ROM_START_ADDR + ROMSIZE));
    wire sel_led = (data_addr == LED_REG_ADDR);

    wire [3:0] data_wr_en_ram = sel_ram ? data_wr_en : 0;
    // this expression uses reduction operator & in (& data_wr_en)
    wire data_wr_en_led = (& data_wr_en) & sel_led;

    // MUX data_rd multiplexer
    wire [31:0] data_rd =
        sel_ram ? data_rd_ram :
        sel_rom ? data_rd_rom :
        sel_led ? {28'h0, led} :
        0;

    ram_memory #(RAMSIZE) Ram (
        .clk(clk),
        .wen(data_wr_en_ram),
        .addr(data_addr - RAM_START_ADDR),
        .wdata(data_wr),
        .rdata(data_rd_ram)
        );

    rom_memory #(ROMSIZE) Rom (
        .address(prog_addr - ROM_START_ADDR),
        .data(prog_data),
        .addressB(data_addr - ROM_START_ADDR),
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
    always @(posedge clk) begin
        if (data_wr_en_led)
            led = data_wr[3:0];
    end

    initial begin
        led = 0;
    end
    
endmodule


// divide the clock by 4
module clk_divider
(
    input clk,
    output out
);

    reg [31:0] div;
    assign out = div[1];

    always @(posedge clk) begin
        div = div + 1;
    end

    initial begin
        div = 0;
    end
endmodule
