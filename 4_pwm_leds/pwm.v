module pwm
(
    input clkin,
    output pin
);

    parameter duty = 500;
    parameter period = 1000;
    reg [31:0] counter;

    assign pin = (counter <= duty) ? 1 : 0;

    always @(posedge clkin)
    begin
    if (counter >= period)
        counter <= 0;
    else
        counter <= counter + 1;
    end

    initial
    begin
        counter = 0;
    end
endmodule
