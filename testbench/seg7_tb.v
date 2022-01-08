`timescale 1ps/1ps

module display7_tb();
    reg clk;
    reg [3:0] led1;
    reg [3:0] led2;
    reg [3:0] led3;
    reg [3:0] led4;
    reg [3:0] led5;
    reg [3:0] led6;
    reg [3:0] led7;
    reg [3:0] led8;

    wire [7:0] ena;
    wire [7:0] ctl;
    display7 display7_0(
        clk,
        led1,
        led2,
        led3,
        led4,
        led5,
        led6,
        led7,
        led8,
        ena,
        ctl
    );
    initial begin 
        clk = 0;
        led1 = 2;
        led2 = 3;
        led3 = 4;
        led4 = 5;
        led5 = 6;
        led6 = 7;
        led7 = 8;
        led8 = 9;
    end
    always #1 clk = ~clk;
endmodule