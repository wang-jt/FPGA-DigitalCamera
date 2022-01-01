module sd_read_photo(
    input                clk                ,
    input                get_photo_mode     ,
    input        [3:0]   select_photo_no    ,
    input                rd_busy            ,
    input                rd_val_en          ,
    output reg           rd_start_en        ,
    output      [18:0]   sd_rd_ram_addr     ,
    output reg  [31:0]   rd_sec_addr        
    );
    /**************************************************************
        参数定义
    ***************************************************************/
    parameter READ_TIME = 1200;
    parameter DIVIDED_CLK = 50000;

    /**************************************************************
        线网定义
    ***************************************************************/
    reg                 send_clk            ;
    reg                 get_photo_mode_0    ;
    reg                 get_photo_mode_1    ;
    reg         [18:0]  sd_rd_ram_addr_t    ;
    wire                get_photo_mode_ena  ;
    integer             cnt = 0             ;
    initial rd_sec_addr <= 0;

    /**************************************************************
        读取时钟产生
    ***************************************************************/
    always @(posedge clk) begin
        cnt <= cnt + 1;
        if(cnt == DIVIDED_CLK) begin
            cnt <= 0;
            send_clk <= 1;
        end
        else
            send_clk <= 0;
    end
   
    /**************************************************************
        模式进入打拍
    ***************************************************************/
    assign get_photo_mode_ena = get_photo_mode_0 & ~get_photo_mode_1;
    always @(posedge clk) begin
        get_photo_mode_0 <= get_photo_mode;
        get_photo_mode_1 <= get_photo_mode_0;
    end

    /**************************************************************
        生成读取信号
    ***************************************************************/
    reg [10:0] start_cnt;
    initial start_cnt <= 0;
    always @(posedge clk) begin
        if(get_photo_mode_ena) begin
            start_cnt <= 1;
            case (select_photo_no)
                4'h0: rd_sec_addr <= 32'd73743;
                4'h1: rd_sec_addr <= 32'd74943;
                4'h2: rd_sec_addr <= 32'd76143;
                4'h3: rd_sec_addr <= 32'd77343;
                4'h4: rd_sec_addr <= 32'd78543;
                4'h5: rd_sec_addr <= 32'd79743;
                4'h6: rd_sec_addr <= 32'd80943;
                4'h7: rd_sec_addr <= 32'd82143;
                4'h8: rd_sec_addr <= 32'd83343;
                4'h9: rd_sec_addr <= 32'd84543;
                4'ha: rd_sec_addr <= 32'd85743;
                4'hb: rd_sec_addr <= 32'd86943;
                4'hc: rd_sec_addr <= 32'd88143;
                4'hd: rd_sec_addr <= 32'd89343;
                4'he: rd_sec_addr <= 32'd90543;
                4'hf: rd_sec_addr <= 32'd91743;
                default: rd_sec_addr <= 32'd73743;
            endcase
        end
        rd_start_en <= 0;
        if(send_clk && ~rd_busy && start_cnt > 0) begin
            rd_start_en <= 1;
            rd_sec_addr <= rd_sec_addr + 1;
            start_cnt <= start_cnt + 1;
            if(start_cnt == READ_TIME) begin
                start_cnt <= 0;
            end
        end
    end

    /**************************************************************
        获取照片写入RAM地址
    ***************************************************************/
    assign sd_rd_ram_addr = (sd_rd_ram_addr_t > 0) ? sd_rd_ram_addr_t - 19'd1 : 19'd0;
    always@(posedge clk) begin
        if(!get_photo_mode) begin
            sd_rd_ram_addr_t <= 19'b0;
        end else if(rd_val_en) begin
            if(sd_rd_ram_addr_t < 19'd307219) begin
                sd_rd_ram_addr_t <= sd_rd_ram_addr_t +19'd1;
            end
            else begin
                sd_rd_ram_addr_t <= 19'd0;
            end
        end
    end

endmodule

module sd_write_photo(
    input                clk                ,  
    input       [3:0]    select_photo_no    ,
    input                caught_photo_mode  ,
    input                wr_req             ,
    input                wr_busy            ,
    output reg           wr_start_en        ,
    output reg  [31:0]   wr_sec_addr        ,
    output      [18:0]   sd_wr_ram_addr
    );

    /**************************************************************
        参数定义
    ***************************************************************/
    parameter READ_TIME = 1200;
    parameter DIVIDED_CLK = 50000;

    /**************************************************************
        线网定义
    ***************************************************************/
    reg [18:0]          sd_wr_ram_addr_t;
    reg                 send_clk;
    initial             wr_sec_addr <= 0;
    integer             cnt = 0;
    
    /**************************************************************
        发送时钟产生
    ***************************************************************/
    always @(posedge clk) begin
        cnt <= cnt + 1;
        if(cnt == DIVIDED_CLK) begin
            cnt <= 0;
            send_clk <= 1;
        end
        else
            send_clk <= 0;
    end
    
    /**************************************************************
        进入模式打拍
    ***************************************************************/
    reg caught_photo_mode_0, caught_photo_mode_1;
    wire caught_photo_mode_ena;
    assign caught_photo_mode_ena = caught_photo_mode_0 & ~caught_photo_mode_1;
    always @(posedge clk) begin
        caught_photo_mode_0 <= caught_photo_mode;
        caught_photo_mode_1 <= caught_photo_mode_0;
    end

    /**************************************************************
        发送信号产生
    ***************************************************************/
    reg [10:0] start_cnt;
    initial start_cnt <= 0;
    always @(posedge clk) begin
        if(caught_photo_mode_ena) begin
            start_cnt <= 1;
            case (select_photo_no)
                4'h0: wr_sec_addr <= 32'd73743;
                4'h1: wr_sec_addr <= 32'd74943;
                4'h2: wr_sec_addr <= 32'd76143;
                4'h3: wr_sec_addr <= 32'd77343;
                4'h4: wr_sec_addr <= 32'd78543;
                4'h5: wr_sec_addr <= 32'd79743;
                4'h6: wr_sec_addr <= 32'd80943;
                4'h7: wr_sec_addr <= 32'd82143;
                4'h8: wr_sec_addr <= 32'd83343;
                4'h9: wr_sec_addr <= 32'd84543;
                4'ha: wr_sec_addr <= 32'd85743;
                4'hb: wr_sec_addr <= 32'd86943;
                4'hc: wr_sec_addr <= 32'd88143;
                4'hd: wr_sec_addr <= 32'd89343;
                4'he: wr_sec_addr <= 32'd90543;
                4'hf: wr_sec_addr <= 32'd91743;
                default: wr_sec_addr <= 32'd73743;
            endcase
        end
        wr_start_en <= 0;
        if(send_clk && ~wr_busy && start_cnt > 0) begin
            wr_start_en <= 1;
            wr_sec_addr <= wr_sec_addr + 1;
            start_cnt <= start_cnt + 1;
            if(start_cnt == READ_TIME) begin
                start_cnt <= 0;
            end
        end
    end
    
    /**************************************************************
        获取照片读取RAM地址
    ***************************************************************/
    assign sd_wr_ram_addr = (sd_wr_ram_addr_t[18] & sd_wr_ram_addr_t[17]) ? (19'b0) : sd_wr_ram_addr_t;
    always@(posedge clk) begin
        if(!caught_photo_mode) begin
            sd_wr_ram_addr_t <= 19'b0;
        end else if(wr_start_en) begin
            sd_wr_ram_addr_t <= sd_wr_ram_addr_t - 19'b1;
        end else if(wr_req) begin
            if(sd_wr_ram_addr_t < 19'd307219) begin
                sd_wr_ram_addr_t <= sd_wr_ram_addr_t +19'd1;
            end
            else begin
                sd_wr_ram_addr_t <= 19'd0;
            end
        end
    end
endmodule