module sd_ctrl(
    input                clk_ref        ,  
    input                clk_ref_180deg , 
    input                rst_n          ,
    
    input                sd_miso        ,
    output               sd_clk         , 
    output  reg          sd_cs          ,
    output  reg          sd_mosi        ,
       
    input                wr_start_en    ,
    input  [31:0]        wr_sec_addr    ,
    input  [15:0]        wr_data        ,             
    output               wr_busy        ,
    output               wr_req         ,
    
    input                rd_start_en    ,
    input  [31:0]        rd_sec_addr    ,
    output               rd_busy        ,
    output               rd_val_en      ,
    output [15:0]        rd_val_data    ,  

    output               sd_init_done
    );

    /**************************************************************
        线网与定义
    ***************************************************************/
    wire                init_sd_clk    ;
    wire                init_sd_cs     ;
    wire                init_sd_mosi   ;
    wire                wr_sd_cs       ; 
    wire                wr_sd_mosi     ;
    wire                rd_sd_cs       ;
    wire                rd_sd_mosi     ;
    assign  sd_clk = (sd_init_done==1'b0)  ?  init_sd_clk  :  clk_ref_180deg; //SD卡的SPI_CLK 设置

    /**************************************************************
        SD卡信号接口选择
    ***************************************************************/
    always @(*) begin
        if(sd_init_done == 1'b0) begin //SD卡初始化完成之前,端口信号和初始化模块信号相连
            sd_cs = init_sd_cs;
            sd_mosi = init_sd_mosi;
        end else if(wr_busy) begin
            sd_cs = wr_sd_cs;
            sd_mosi = wr_sd_mosi;   
        end else if(rd_busy) begin
            sd_cs = rd_sd_cs;
            sd_mosi = rd_sd_mosi;       
        end else begin
            sd_cs = 1'b1;
            sd_mosi = 1'b1;
        end    
    end    

    /**************************************************************
        SD卡初始化模块实例化
    ***************************************************************/
    sd_init sd_init_0(
        .clk_ref            (clk_ref)           ,
        .rst_n              (rst_n)             ,
        .sd_miso            (sd_miso)           ,
        .sd_clk             (init_sd_clk)       ,
        .sd_cs              (init_sd_cs)        ,
        .sd_mosi            (init_sd_mosi)      ,
        .sd_init_done       (sd_init_done)
    );
    /**************************************************************
        SD卡写数据模块实例化
    ***************************************************************/
    sd_write sd_write_0(
        .clk_ref            (clk_ref)           ,
        .clk_ref_180deg     (clk_ref_180deg)    ,
        .rst_n              (rst_n)             ,
        .sd_miso            (sd_miso)           ,
        .sd_cs              (wr_sd_cs)          ,
        .sd_mosi            (wr_sd_mosi)        ,
        .wr_start_en        (wr_start_en & sd_init_done),  
        .wr_sec_addr        (wr_sec_addr)       ,
        .wr_data            (wr_data)           ,
        .wr_busy            (wr_busy)           ,
        .wr_req             (wr_req)
    );
    /**************************************************************
        SD卡读数据模块实例化
    ***************************************************************/
    sd_read u_sd_read(
        .clk_ref            (clk_ref)           ,
        .clk_ref_180deg     (clk_ref_180deg)    ,
        .rst_n              (rst_n)             ,
        .sd_miso            (sd_miso)           ,
        .sd_cs              (rd_sd_cs)          ,
        .sd_mosi            (rd_sd_mosi)        ,    
        .rd_start_en        (rd_start_en & sd_init_done),  
        .rd_sec_addr        (rd_sec_addr)       ,
        .rd_busy            (rd_busy)           ,
        .rd_val_en          (rd_val_en)         ,
        .rd_val_data        (rd_val_data)       
    );

endmodule