module ov2640_sccb_cfg_init_tb();
    reg clk;
    reg ctl;
    reg rst;
    wire sio_c;
    wire sio_d;
    wire reset,pwdn,xclk;
    wire camera_init_done;
    ov2640_sccb_cfg_init ov2640_sccb_cfg_init_0(
        clk,
        rst,
        sio_c,
        sio_d,
        reset,
        pwdn,
        xclk,
        4'b0,
        camera_init_done
    );
    initial begin
        clk = 0; rst = 0;ctl = 0;
    end
    always #1 clk = ~clk;
endmodule