`timescale 1ps/1ps

module vga_driver_tb();
    reg vga_clk, sys_rst_n;
    reg [11:0] pixel_data;
    wire vga_hs, vga_vs;
    wire [11:0] vga_rgb;
    wire data_req;
    wire [18:0] pixel_addr;
    vga_driver vga_driver_0(
        vga_clk,
        sys_rst_n,
        vga_hs,
        vga_vs,
        vga_rgb,
        data_req,
        pixel_data,
        pixel_addr
    );
    
    initial begin
        vga_clk = 0;sys_rst_n =1;
        pixel_data = 0;
    end
    always @(pixel_addr)
        pixel_data <= pixel_addr[11:0];

    always #1 vga_clk = ~vga_clk;
    
endmodule