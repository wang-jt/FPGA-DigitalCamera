module bluetooth_mode_control(
    input               sys_clk             ,
    input               sys_rst             ,
    input               bluetooth_rxd       ,   //蓝牙RXD
    output reg          get_photo_mode      ,   //读取模式
    output reg          caught_photo_mode   ,   //拍摄模式
    output reg          camera_show_mode    ,   //取景模式
    output reg [3:0]    select_photo_no         //当前照片位选择地址
);
    /**************************************************************
    线网与寄存器定义
    ***************************************************************/
    wire                uart_done;
    wire [7:0]          uart_data;

    /**************************************************************
    寄存器初始化
    ***************************************************************/
    initial begin
        get_photo_mode <= 0;
        caught_photo_mode <= 0;
        camera_show_mode <= 1;
        select_photo_no <= 4'b0;
    end
    /**************************************************************
    蓝牙接受器实例化
    ***************************************************************/
    uart_recv uart_recv_0(
        .sys_clk        (sys_clk),
        .sys_rst_n      (~sys_rst),
        .uart_rxd       (bluetooth_rxd),
        .uart_done      (uart_done),
        .uart_data      (uart_data)
    );
    
    /**************************************************************
    uart_done打拍获取上升沿
    ***************************************************************/
    reg uart_done_0, uart_done_1;
    wire uart_done_ena;
    assign uart_done_ena = uart_done_0 & ~uart_done_1;
    always @(posedge sys_clk) begin
        uart_done_0 <= uart_done;
        uart_done_1 <= uart_done_0;
    end

    /**************************************************************
    收到蓝牙命令后的模式切换
    ***************************************************************/
    always @(posedge sys_clk) begin
        if(uart_done_ena) begin
            if(uart_data[7:4] == 4'h0) begin                //0x0X，代表选择X号照片位置
                select_photo_no <= uart_data[3:0];
            end else if(uart_data[7:4] == 4'h1) begin       //0x1X，模式选择模式
            case(uart_data[3:0])
                4'h0: begin
                    get_photo_mode <= 0;
                    caught_photo_mode <= 0;
                    camera_show_mode <= 0;
                end
                4'h1: begin
                    get_photo_mode <= 1;
                    caught_photo_mode <= 0;
                    camera_show_mode <= 0;
                end
                4'h2: begin
                    get_photo_mode <= 0;
                    caught_photo_mode <= 1;
                    camera_show_mode <= 0;
                end
                4'h3: begin
                    get_photo_mode <= 0;
                    caught_photo_mode <= 0;
                    camera_show_mode <= 1;
                end
            endcase
            end else if(uart_data[7:4] == 4'h3) begin       //0x3X，照片位1位1位切换
            case(uart_data[3:0])
                4'h0: begin
                    if(select_photo_no < 4'hf)
                        select_photo_no <= select_photo_no + 1;
                end
                4'h1: begin
                    if(select_photo_no > 4'h0)
                        select_photo_no <= select_photo_no - 1;
                end
            endcase
            end
        end
    end

endmodule