module ov2640_sccb_cfg_init(
    input               clk         ,
    input               rst         ,
    output              sio_c       ,
    inout               sio_d       ,
    output              reset       ,
    output              pwdn        ,
    output              xclk        ,
    input      [3:0]    bright      ,
    output              camera_init_done
);

    /**************************************************************
        线网定义
    ***************************************************************/
    wire [15:0]         data_send   ;
    wire                cfg_ok      ;
    wire                sccb_ok     ;

    /**************************************************************
        线网连接
    ***************************************************************/
    assign reset = 1;
    assign pwdn = 0;
    assign xclk = clk;
    pullup up (sio_d);

    /**************************************************************
        配置文件模块实例化
    ***************************************************************/    
    ov2460_sccb_cfg ov2460_sccb_cfg_0(
        .clk            (clk)           ,
        .rst            (rst)           ,
        .data_out       (data_send)     ,
        .cfg_ok         (cfg_ok)        ,
        .sccb_ok        (sccb_ok)       ,
        .bright         (bright)        
    );

    /**************************************************************
        SCCB总线驱动模块实例化
    ***************************************************************/   
    ov2640_sccb_driver ov2640_sccb_driver_0(
        .clk            (clk)           ,
        .rst            (rst)           ,
        .sio_d          (sio_d)         ,
        .sio_c          (sio_c)         ,
        .cfg_ok         (cfg_ok)        ,
        .sccb_ok        (sccb_ok)       ,
        .slave_id       (8'h60)         ,
        .cfg_addr       (data_send[15:8]),
        .value          (data_send[7:0])
    );

    /**************************************************************
        摄像头初始化完成信号打拍
    ***************************************************************/   
    reg camera_init_done_0;
    reg camera_init_done_1;
    assign camera_init_done = camera_init_done_0 & ~camera_init_done_1;
    always @(posedge clk) begin
        if(rst) begin
            camera_init_done_0 <= 0;
            camera_init_done_1 <= 0;
        end else if(~camera_init_done) begin
            camera_init_done_0 <= sccb_ok;
            camera_init_done_1 <= camera_init_done_0;
        end
    end

endmodule