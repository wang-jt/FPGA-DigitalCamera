module vga_driver(
    input               vga_clk         ,
    input               sys_rst_n       ,                         
    output              vga_hs          ,
    output              vga_vs          ,
    output      [11:0]  vga_rgb         ,
    output              data_req        ,
    input       [11:0]  pixel_data      ,
    output reg  [18:0]  pixel_addr
);                             
                                                        
    /**************************************************************
        参数定义
    ***************************************************************/ 
    parameter  H_SYNC   =  10'd96   ;   //行同步
    parameter  H_BACK   =  10'd48   ;   //行显示后沿
    parameter  H_DISP   =  10'd640  ;   //行有效数据
    parameter  H_FRONT  =  10'd16   ;   //行显示前沿
    parameter  H_TOTAL  =  10'd800  ;   //行扫描周期

    parameter  V_SYNC   =  10'd2    ;   //场同步
    parameter  V_BACK   =  10'd33   ;   //场显示后沿
    parameter  V_DISP   =  10'd480  ;   //场有效数据
    parameter  V_FRONT  =  10'd10   ;   //场显示前沿
    parameter  V_TOTAL  =  10'd525  ;   //场扫描周期
            
    /**************************************************************
        线网与寄存器定义
    ***************************************************************/                                  
    reg  [9:0]          hsync_cnt       ;
    reg  [9:0]          vsync_cnt       ;
    wire                vga_en          ;
    wire                data_req        ;


    /**************************************************************
        线网连接
    ***************************************************************/    
    assign vga_hs  = (hsync_cnt <= H_SYNC - 1'b1) ? 1'b0 : 1'b1;    //行同步信号
    assign vga_vs  = (vsync_cnt <= V_SYNC - 1'b1) ? 1'b0 : 1'b1;    //场同步信号
    assign vga_en  = (((hsync_cnt >= H_SYNC+H_BACK) && (hsync_cnt < H_SYNC+H_BACK+H_DISP))
                    &&((vsync_cnt >= V_SYNC+V_BACK) && (vsync_cnt < V_SYNC+V_BACK+V_DISP)))
                    ?  1'b1 : 1'b0;                                 //VGA输出信号           
    assign vga_rgb = vga_en ? pixel_data : 12'd0;                   //RGB444输出信号
    assign data_req = (((hsync_cnt >= H_SYNC+H_BACK-1'b1) && (hsync_cnt < H_SYNC+H_BACK+H_DISP-1'b1))
                    && ((vsync_cnt >= V_SYNC+V_BACK) && (vsync_cnt < V_SYNC+V_BACK+V_DISP)))
                    ?  1'b1 : 1'b0;                                 //像素点请求信号

    /**************************************************************
        像素点地址信号
    ***************************************************************/                
    always @(posedge vga_clk or negedge sys_rst_n) begin
        if (!sys_rst_n)
            pixel_addr <= 0;
        else if(data_req)
            pixel_addr <= (hsync_cnt - (H_SYNC + H_BACK - 1'b1)) + H_DISP * (vsync_cnt - (V_SYNC + V_BACK - 1'b1));
        else
            pixel_addr <= 0;
    end

    /**************************************************************
        行同步计数器
    ***************************************************************/  
    always @(posedge vga_clk or negedge sys_rst_n) begin         
        if (!sys_rst_n)
            hsync_cnt <= 10'd0;                                  
        else begin
            if(hsync_cnt < H_TOTAL - 1'b1)                                               
                hsync_cnt <= hsync_cnt + 1'b1;                               
            else 
                hsync_cnt <= 10'd0;  
        end
    end

    /**************************************************************
        场同步计数器
    ***************************************************************/  
    always @(posedge vga_clk or negedge sys_rst_n) begin         
        if (!sys_rst_n)
            vsync_cnt <= 10'd0;                                  
        else if(hsync_cnt == H_TOTAL - 1'b1) begin
            if(vsync_cnt < V_TOTAL - 1'b1)                                               
                vsync_cnt <= vsync_cnt + 1'b1;                               
            else 
                vsync_cnt <= 10'd0;  
        end
    end

endmodule 