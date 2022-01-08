module sd_read(
    input                clk_ref       ,
    input                clk_ref_180deg,
    input                rst_n         ,
    input                sd_miso       ,
    output  reg          sd_cs         ,
    output  reg          sd_mosi       ,
    input                rd_start_en   ,
    input        [31:0]  rd_sec_addr   ,                      
    output  reg          rd_busy       ,
    output  reg          rd_val_en     ,
    output  reg  [15:0]  rd_val_data   
    );

    /**************************************************************
        线网与寄存器定义
    ***************************************************************/
    reg            rd_en_d0      ;
    reg            rd_en_d1      ;                                
    reg            res_en        ;    
    reg    [7:0]   res_data      ;                 
    reg            res_flag      ;          
    reg    [5:0]   res_bit_cnt   ;                
                                
    reg            rx_en_t       ;
    reg    [15:0]  rx_data_t     ;
    reg            rx_flag       ;
    reg    [3:0]   rx_bit_cnt    ;
    reg    [8:0]   rx_data_cnt   ;
    reg            rx_finish_en  ;
                                
    reg    [3:0]   rd_ctrl_cnt   ;
    reg    [47:0]  cmd_rd        ;
    reg    [5:0]   cmd_bit_cnt   ;
    reg            rd_data_flag  ;
    wire           pos_rd_en     ;
    assign  pos_rd_en = (~rd_en_d1) & rd_en_d0;

    /**************************************************************
        rd_start_en信号延时打拍
    ***************************************************************/
    always @(posedge clk_ref or negedge rst_n) begin
        if(!rst_n) begin
            rd_en_d0 <= 1'b0;
            rd_en_d1 <= 1'b0;
        end else begin
            rd_en_d0 <= rd_start_en;
            rd_en_d1 <= rd_en_d0;
        end        
    end  

    /**************************************************************
        接收sd卡返回的响应数据
    ***************************************************************/
    always @(posedge clk_ref_180deg or negedge rst_n) begin
        if(!rst_n) begin
            res_en <= 1'b0;
            res_data <= 8'd0;
            res_flag <= 1'b0;
            res_bit_cnt <= 6'd0;
        end else begin
            if(sd_miso == 1'b0 && res_flag == 1'b0) begin
                res_flag <= 1'b1;
                res_data <= {res_data[6:0],sd_miso};
                res_bit_cnt <= res_bit_cnt + 6'd1;
                res_en <= 1'b0;
            end else if(res_flag) begin
                res_data <= {res_data[6:0],sd_miso};
                res_bit_cnt <= res_bit_cnt + 6'd1;
                if(res_bit_cnt == 6'd7) begin
                    res_flag <= 1'b0;
                    res_bit_cnt <= 6'd0;
                    res_en <= 1'b1; 
                end                
            end  
            else
                res_en <= 1'b0;        
        end
    end 

    /**************************************************************
        接收SD卡有效数据
    ***************************************************************/
    always @(posedge clk_ref_180deg or negedge rst_n) begin
        if(!rst_n) begin
            rx_en_t <= 1'b0;
            rx_data_t <= 16'd0;
            rx_flag <= 1'b0;
            rx_bit_cnt <= 4'd0;
            rx_data_cnt <= 9'd0;
            rx_finish_en <= 1'b0;
        end else begin
            rx_en_t <= 1'b0; 
            rx_finish_en <= 1'b0;
            if(rd_data_flag && sd_miso == 1'b0 && rx_flag == 1'b0)    
                rx_flag <= 1'b1;   
            else if(rx_flag) begin
                rx_bit_cnt <= rx_bit_cnt + 4'd1;
                rx_data_t <= {rx_data_t[14:0],sd_miso};
                if(rx_bit_cnt == 4'd15) begin 
                    rx_data_cnt <= rx_data_cnt + 9'd1;
                    if(rx_data_cnt <= 9'd255)                        
                        rx_en_t <= 1'b1;  
                    else if(rx_data_cnt == 9'd257) begin
                        rx_flag <= 1'b0;
                        rx_finish_en <= 1'b1;
                        rx_data_cnt <= 9'd0;               
                        rx_bit_cnt <= 4'd0;
                    end    
                end                
            end       
            else
                rx_data_t <= 16'd0;
        end    
    end    

    /**************************************************************
        寄存输出数据有效信号和数据
    ***************************************************************/
    always @(posedge clk_ref or negedge rst_n) begin
        if(!rst_n) begin
            rd_val_en <= 1'b0;
            rd_val_data <= 16'd0;
        end
        else begin
            if(rx_en_t) begin
                rd_val_en <= 1'b1;
                rd_val_data <= rx_data_t;
            end    
            else
                rd_val_en <= 1'b0;
        end
    end              

    /**************************************************************
        读命令产生
    ***************************************************************/
    always @(posedge clk_ref or negedge rst_n) begin
        if(!rst_n) begin
            sd_cs <= 1'b1;
            sd_mosi <= 1'b1;        
            rd_ctrl_cnt <= 4'd0;
            cmd_rd <= 48'd0;
            cmd_bit_cnt <= 6'd0;
            rd_busy <= 1'b0;
            rd_data_flag <= 1'b0;
        end else begin
            case(rd_ctrl_cnt)
                4'd0 : begin
                    rd_busy <= 1'b0;
                    sd_cs <= 1'b1;
                    sd_mosi <= 1'b1;
                    if(pos_rd_en) begin
                        cmd_rd <= {8'h51,rd_sec_addr,8'hff};    //写入单个命令块CMD17
                        rd_ctrl_cnt <= rd_ctrl_cnt + 4'd1;
                        rd_busy <= 1'b1;                      
                    end    
                end
                4'd1 : begin
                    if(cmd_bit_cnt <= 6'd47) begin              //开始按位发送读命令
                        cmd_bit_cnt <= cmd_bit_cnt + 6'd1;
                        sd_cs <= 1'b0;
                        sd_mosi <= cmd_rd[6'd47 - cmd_bit_cnt]; 
                    end    
                    else begin                                  
                        sd_mosi <= 1'b1;
                        if(res_en) begin                        //SD卡响应
                            rd_ctrl_cnt <= rd_ctrl_cnt + 4'd1;  
                            cmd_bit_cnt <= 6'd0;
                        end    
                    end    
                end    
                4'd2 : begin
                    rd_data_flag <= 1'b1;                       
                    if(rx_finish_en) begin                      //数据接收完成
                        rd_ctrl_cnt <= rd_ctrl_cnt + 4'd1; 
                        rd_data_flag <= 1'b0;
                        sd_cs <= 1'b1;
                    end
                end        
                default : begin
                    sd_cs <= 1'b1;   
                    rd_ctrl_cnt <= rd_ctrl_cnt + 4'd1;
                end    
            endcase
        end         
    end

endmodule

module sd_write(
    input                clk_ref        ,
    input                clk_ref_180deg ,
    input                rst_n          ,
    input                sd_miso        ,
    output  reg          sd_cs          ,
    output  reg          sd_mosi        , 
    input                wr_start_en    ,
    input  [31:0]       wr_sec_addr     ,
    input  [15:0]       wr_data         ,                     
    output  reg          wr_busy        ,
    output  reg          wr_req 
    );

    /**************************************************************
        寄存器与参数定义
    ***************************************************************/
    parameter  HEAD_BYTE = 8'hfe    ;      //写命令命令头                                    
    reg            wr_en_d0         ;
    reg            wr_en_d1         ;   
    reg            res_en           ;   
    reg    [7:0]   res_data         ;           
    reg            res_flag         ;
    reg    [5:0]   res_bit_cnt      ;                                         
    reg    [3:0]   wr_ctrl_cnt      ;
    reg    [47:0]  cmd_wr           ; 
    reg    [5:0]   cmd_bit_cnt      ;
    reg    [3:0]   bit_cnt          ;
    reg    [8:0]   data_cnt         ;
    reg    [15:0]  wr_data_t        ;
    reg            detect_done_flag ;
    reg    [7:0]   detect_data      ;
    wire           pos_wr_en        ;
    assign  pos_wr_en = (~wr_en_d1) & wr_en_d0;

    /**************************************************************
        wr_start_en信号延时打拍
    ***************************************************************/
    always @(posedge clk_ref or negedge rst_n) begin
        if(!rst_n) begin
            wr_en_d0 <= 1'b0;
            wr_en_d1 <= 1'b0;
        end else begin
            wr_en_d0 <= wr_start_en;
            wr_en_d1 <= wr_en_d0;
        end        
    end 

    /**************************************************************
        接收sd卡返回的响应数据
    ***************************************************************/
    always @(posedge clk_ref_180deg or negedge rst_n) begin
        if(!rst_n) begin
            res_en <= 1'b0;
            res_data <= 8'd0;
            res_flag <= 1'b0;
            res_bit_cnt <= 6'd0;
        end else begin
            if(sd_miso == 1'b0 && res_flag == 1'b0) begin
                res_flag <= 1'b1;
                res_data <= {res_data[6:0],sd_miso};
                res_bit_cnt <= res_bit_cnt + 6'd1;
                res_en <= 1'b0;
            end    
            else if(res_flag) begin
                res_data <= {res_data[6:0],sd_miso};
                res_bit_cnt <= res_bit_cnt + 6'd1;
                if(res_bit_cnt == 6'd7) begin
                    res_flag <= 1'b0;
                    res_bit_cnt <= 6'd0;
                    res_en <= 1'b1; 
                end                
            end  
            else
                res_en <= 1'b0;       
        end
    end 

    /**************************************************************
        检测SD卡是否空闲
    ***************************************************************/
    always @(posedge clk_ref or negedge rst_n) begin
        if(!rst_n)
            detect_data <= 8'd0;   
        else if(detect_done_flag)
            detect_data <= {detect_data[6:0],sd_miso};
        else
            detect_data <= 8'd0;    
    end        

    /**************************************************************
        SD卡写入数据
    ***************************************************************/
    always @(posedge clk_ref or negedge rst_n) begin
        if(!rst_n) begin
            sd_cs <= 1'b1;
            sd_mosi <= 1'b1; 
            wr_ctrl_cnt <= 4'd0;
            wr_busy <= 1'b0;
            cmd_wr <= 48'd0;
            cmd_bit_cnt <= 6'd0;
            bit_cnt <= 4'd0;
            wr_data_t <= 16'd0;
            data_cnt <= 9'd0;
            wr_req <= 1'b0;
            detect_done_flag <= 1'b0;
        end
        else begin
            wr_req <= 1'b0;
            case(wr_ctrl_cnt)
                4'd0 : begin
                    wr_busy <= 1'b0;                          //写空闲
                    sd_cs <= 1'b1;                                 
                    sd_mosi <= 1'b1;                               
                    if(pos_wr_en) begin                            
                        cmd_wr <= {8'h58,wr_sec_addr,8'hff};    //CMD24
                        wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;
                        wr_busy <= 1'b1;                      
                    end                                            
                end   
                4'd1 : begin
                    if(cmd_bit_cnt <= 6'd47) begin              //发送写命令
                        cmd_bit_cnt <= cmd_bit_cnt + 6'd1;
                        sd_cs <= 1'b0;
                        sd_mosi <= cmd_wr[6'd47 - cmd_bit_cnt];           
                    end    
                    else begin
                        sd_mosi <= 1'b1;
                        if(res_en) begin 
                            wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;
                            cmd_bit_cnt <= 6'd0;
                            bit_cnt <= 4'd1;
                        end    
                    end     
                end                                                                                                     
                4'd2 : begin                                       
                    bit_cnt <= bit_cnt + 4'd1;          
                    if(bit_cnt>=4'd8 && bit_cnt <= 4'd15) begin
                        sd_mosi <= HEAD_BYTE[4'd15-bit_cnt];
                        if(bit_cnt == 4'd14)                       
                            wr_req <= 1'b1;
                        else if(bit_cnt == 4'd15)                  
                            wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;
                    end                                            
                end                                                
                4'd3 : begin                                    //写入数据
                    bit_cnt <= bit_cnt + 4'd1;                     
                    if(bit_cnt == 4'd0) begin                      
                        sd_mosi <= wr_data[4'd15-bit_cnt];
                        wr_data_t <= wr_data; 
                    end                                            
                    else                                           
                        sd_mosi <= wr_data_t[4'd15-bit_cnt];
                    if((bit_cnt == 4'd14) && (data_cnt <= 9'd255)) 
                        wr_req <= 1'b1;                          
                    if(bit_cnt == 4'd15) begin                     
                        data_cnt <= data_cnt + 9'd1;        
                        if(data_cnt == 9'd255) begin
                            data_cnt <= 9'd0;                   
                            wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;      
                        end                                        
                    end                                            
                end                                          
                4'd4 : begin                                    //CRC校验   
                    bit_cnt <= bit_cnt + 4'd1;                  
                    sd_mosi <= 1'b1;                 
                    //crc写入完成,控制计数器加1              
                    if(bit_cnt == 4'd15)                           
                        wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;            
                end                                                
                4'd5 : begin                                    
                    if(res_en)                                    
                        wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;         
                end                                                
                4'd6 : begin                                         
                    detect_done_flag <= 1'b1;                   //写入完成
                    if(detect_data == 8'hff) begin              
                        wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;         
                        detect_done_flag <= 1'b0;                  
                    end         
                end    
                default : begin
                    sd_cs <= 1'b1;   
                    wr_ctrl_cnt <= wr_ctrl_cnt + 4'd1;
                end     
            endcase
        end
    end            

endmodule