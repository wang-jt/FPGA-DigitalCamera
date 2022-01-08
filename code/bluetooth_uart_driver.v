module uart_recv(
    input               sys_clk     ,
    input               sys_rst_n   ,
    input               uart_rxd    ,
    output reg          uart_done   ,   //接受成功后拉高
    output reg [7:0]    uart_data
    );

    /**************************************************************
    参数定义
    ***************************************************************/
    parameter  CLK_FREQ = 100000000;            //系统时钟频率
    parameter  UART_BPS = 9600;                 //串口波特率
    localparam BPS_CNT  = CLK_FREQ/UART_BPS;

    /**************************************************************
    线网与寄存器定义
    ***************************************************************/
    reg             uart_rxd_0;
    reg             uart_rxd_1;
    reg [15:0]      clk_cnt;
    reg [3:0]       rx_cnt;
    reg             rx_flag;
    reg [7:0]       rx_data;


    /**************************************************************
    uart_rxd打拍、获取传输开始信号
    ***************************************************************/
    wire       start_flag;
    assign  start_flag = uart_rxd_1 & (~uart_rxd_0);    
    always @(posedge sys_clk or negedge sys_rst_n) begin 
        if (!sys_rst_n) begin 
            uart_rxd_0 <= 1'b0;
            uart_rxd_1 <= 1'b0;          
        end
        else begin
            uart_rxd_0  <= uart_rxd;                   
            uart_rxd_1  <= uart_rxd_0;
        end   
    end

    /**************************************************************
    开始接受、设置接受状态信号
    ***************************************************************/
    always @(posedge sys_clk or negedge sys_rst_n) begin         
        if (!sys_rst_n)                                  
            rx_flag <= 1'b0;
        else begin
            if(start_flag)
                rx_flag <= 1'b1;
            else if((rx_cnt == 4'd9)&&(clk_cnt == BPS_CNT/2))
                rx_flag <= 1'b0;
            else
                rx_flag <= rx_flag;
        end
    end
    
    /**************************************************************
    根据波特率产生对应时钟
    ***************************************************************/
    always @(posedge sys_clk or negedge sys_rst_n) begin         
        if (!sys_rst_n) begin                             
            clk_cnt <= 16'd0;                                  
            rx_cnt  <= 4'd0;
        end else if ( rx_flag ) begin
                if (clk_cnt < BPS_CNT - 1) begin
                    clk_cnt <= clk_cnt + 1'b1;
                    rx_cnt  <= rx_cnt;
                end else begin
                    clk_cnt <= 16'd0;
                    rx_cnt  <= rx_cnt + 1'b1;
                end
            end else begin
                clk_cnt <= 16'd0;
                rx_cnt  <= 4'd0;
            end
    end
    
    /**************************************************************
    数据接收过程
    ***************************************************************/
    always @(posedge sys_clk or negedge sys_rst_n) begin 
        if ( !sys_rst_n)  
            rx_data <= 8'd0;                                     
        else if(rx_flag)
            if (clk_cnt == BPS_CNT/2) begin
                case ( rx_cnt )
                4'd1 : rx_data[0] <= uart_rxd_1;
                4'd2 : rx_data[1] <= uart_rxd_1;
                4'd3 : rx_data[2] <= uart_rxd_1;
                4'd4 : rx_data[3] <= uart_rxd_1;
                4'd5 : rx_data[4] <= uart_rxd_1;
                4'd6 : rx_data[5] <= uart_rxd_1;
                4'd7 : rx_data[6] <= uart_rxd_1;
                4'd8 : rx_data[7] <= uart_rxd_1;
                default:;                                    
                endcase
            end
            else 
                rx_data <= rx_data;
        else
            rx_data <= 8'd0;
    end
    
    /**************************************************************
    数据接受完毕，准备收尾
    ***************************************************************/
    always @(posedge sys_clk or negedge sys_rst_n) begin        
        if (!sys_rst_n) begin
            uart_data <= 8'd0;                               
            uart_done <= 1'b0;
        end
        else if(rx_cnt == 4'd9) begin    
            uart_data <= rx_data; 
            uart_done <= 1'b1;
        end
        else begin
            uart_data <= 8'd0;                                   
            uart_done <= 1'b0; 
        end    
    end
endmodule	

module uart_send(
    input               sys_clk     ,
    input               sys_rst_n   ,
    input               uart_en     ,
    input  [7:0]        uart_din    , 
    output  reg         uart_txd
    );

    /**************************************************************
    参数定义
    ***************************************************************/
    parameter  CLK_FREQ = 100000000; 
    parameter  UART_BPS = 9600;
    localparam BPS_CNT  = CLK_FREQ/UART_BPS;

    /**************************************************************
    线网与寄存器定义
    ***************************************************************/
 
    reg [15:0]      clk_cnt;
    reg [ 3:0]      tx_cnt;//发送数据计数器
    reg             tx_flag;//发送过程标志信号
    reg [ 7:0]      tx_data;
    wire            en_flag;

    /**************************************************************
    uart_en打拍，获取开始使能上升沿
    ***************************************************************/
    reg             uart_en_0; 
    reg             uart_en_1; 
    assign en_flag = (~uart_en_1) & uart_en_0;                                         
    always @(posedge sys_clk or negedge sys_rst_n) begin         
        if (!sys_rst_n) begin
            uart_en_0 <= 1'b0;                                  
            uart_en_1 <= 1'b0;
        end else begin                                               
            uart_en_0 <= uart_en;                               
            uart_en_1 <= uart_en_0;                            
        end
    end

    /**************************************************************
    发送中相关发送信号控制
    ***************************************************************/     
    always @(posedge sys_clk or negedge sys_rst_n) begin         
        if (!sys_rst_n) begin                                  
            tx_flag <= 1'b0;
            tx_data <= 8'd0;
        end else if (en_flag) begin                 
            tx_flag <= 1'b1;
            tx_data <= uart_din;
        end else if ((tx_cnt == 4'd9)&&(clk_cnt == BPS_CNT/2)) begin 
            tx_flag <= 1'b0;
            tx_data <= 8'd0;
        end else begin
            tx_flag <= tx_flag;
            tx_data <= tx_data;
        end 
    end

    /**************************************************************
    进入发送过程，根据波特率设置对应时钟
    ***************************************************************/
    always @(posedge sys_clk or negedge sys_rst_n) begin         
        if (!sys_rst_n) begin                             
            clk_cnt <= 16'd0;                                  
            tx_cnt  <= 4'd0;
        end  else if (tx_flag) begin
            if (clk_cnt < BPS_CNT - 1) begin
                clk_cnt <= clk_cnt + 1'b1;
                tx_cnt  <= tx_cnt;
            end else begin
                clk_cnt <= 16'd0;
                tx_cnt  <= tx_cnt + 1'b1;
            end
        end else begin //发送过程结束
            clk_cnt <= 16'd0;
            tx_cnt  <= 4'd0;
        end
    end

    /**************************************************************
    数据发送过程
    ***************************************************************/
    always @(posedge sys_clk or negedge sys_rst_n) begin        
        if (!sys_rst_n)  
            uart_txd <= 1'b1;        
        else if (tx_flag)
            case(tx_cnt)
                4'd0: uart_txd <= 1'b0;
                4'd1: uart_txd <= tx_data[0];
                4'd2: uart_txd <= tx_data[1];
                4'd3: uart_txd <= tx_data[2];
                4'd4: uart_txd <= tx_data[3];
                4'd5: uart_txd <= tx_data[4];
                4'd6: uart_txd <= tx_data[5];
                4'd7: uart_txd <= tx_data[6];
                4'd8: uart_txd <= tx_data[7];
                4'd9: uart_txd <= 1'b1;
                default: ;
            endcase
        else 
            uart_txd <= 1'b1;
    end
endmodule	          