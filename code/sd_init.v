module sd_init(
    input          clk_ref       ,
    input          rst_n         ,
    
    input          sd_miso       ,
    output         sd_clk        ,
    output  reg    sd_cs         ,
    output  reg    sd_mosi       ,
    output  reg    sd_init_done
    );

    /**************************************************************
        参数定义
    ***************************************************************/
    parameter  CMD0  = {8'h40,8'h00,8'h00,8'h00,8'h00,8'h95};   //复位命令
    parameter  CMD8  = {8'h48,8'h00,8'h00,8'h01,8'haa,8'h87};   //接口状态查询命令
    parameter  CMD55 = {8'h77,8'h00,8'h00,8'h00,8'h00,8'hff};   //应用指令
    parameter  ACMD41= {8'h69,8'h40,8'h00,8'h00,8'h00,8'hff};   //发送操作寄存器指令
    
    parameter  DIV_FREQ = 200;                                  //初始化时钟分频系数
    parameter  POWER_ON_NUM = 5000;                             //上电等待时间
    parameter  OVER_TIME_NUM = 25000;                           //响应超时时间
                        
    parameter  st_idle        = 7'b000_0001;                    //上电等待SD卡稳定
    parameter  st_send_cmd0   = 7'b000_0010;                    //发送软件复位命令
    parameter  st_wait_cmd0   = 7'b000_0100;                    //等待SD卡响应
    parameter  st_send_cmd8   = 7'b000_1000;                    //检查SD卡版本
    parameter  st_send_cmd55  = 7'b001_0000;                    //应用指令切换
    parameter  st_send_acmd41 = 7'b010_0000;                    //发送寄存器配置
    parameter  st_init_done   = 7'b100_0000;                    //SD卡初始化完成

    /**************************************************************
        寄存器与线网配置
    ***************************************************************/
    reg    [7:0]   cur_state      ;
    reg    [7:0]   next_state     ;                             
    reg    [7:0]   div_cnt        ;    
    reg            div_clk        ;      
    reg    [12:0]  poweron_cnt    ;   
    reg            res_en         ;    
    reg    [47:0]  res_data       ;    
    reg            res_flag       ;    
    reg    [5:0]   res_bit_cnt    ;                             
    reg    [5:0]   cmd_bit_cnt    ;    
    reg    [15:0]  over_time_cnt  ;    
    reg            over_time_en   ;                                 
    wire           div_clk_180deg ;

    
    assign  sd_clk = ~div_clk;         
    assign  div_clk_180deg = ~div_clk; 
    /**************************************************************
        时钟分频
    ***************************************************************/
    always @(posedge clk_ref or negedge rst_n) begin
        if(!rst_n) begin
            div_clk <= 1'b0;
            div_cnt <= 8'd0;
        end
        else begin
            if(div_cnt == DIV_FREQ/2-1'b1) begin
                div_clk <= ~div_clk;
                div_cnt <= 8'd0;
            end
            else    
                div_cnt <= div_cnt + 1'b1;
        end        
    end

    /**************************************************************
        商店等待稳定
    ***************************************************************/
    always @(posedge div_clk or negedge rst_n) begin
        if(!rst_n) 
            poweron_cnt <= 13'd0;
        else if(cur_state == st_idle) begin
            if(poweron_cnt < POWER_ON_NUM)
                poweron_cnt <= poweron_cnt + 1'b1;                   
        end
        else
            poweron_cnt <= 13'd0;    
    end    

    /**************************************************************
        接收sd卡返回的响应数据
    ***************************************************************/
    always @(posedge div_clk_180deg or negedge rst_n) begin
        if(!rst_n) begin
            res_en <= 1'b0;
            res_data <= 48'd0;
            res_flag <= 1'b0;
            res_bit_cnt <= 6'd0;
        end else begin
            //sd_miso = 0 开始接收响应数据
            if(sd_miso == 1'b0 && res_flag == 1'b0) begin 
                res_flag <= 1'b1;
                res_data <= {res_data[46:0],sd_miso};
                res_bit_cnt <= res_bit_cnt + 6'd1;
                res_en <= 1'b0;
            end else if(res_flag) begin
                //R1返回1个字节,R3 R7返回5个字节
                //在这里统一按照6个字节来接收,多出的1个字节为NOP(8个时钟周期的延时)
                res_data <= {res_data[46:0],sd_miso};     
                res_bit_cnt <= res_bit_cnt + 6'd1;
                if(res_bit_cnt == 6'd47) begin
                    res_flag <= 1'b0;
                    res_bit_cnt <= 6'd0;
                    res_en <= 1'b1; 
                end                
            end else
                res_en <= 1'b0;         
        end
    end                    

    /**************************************************************
       状态依据分频时钟推进
    ***************************************************************/
    always @(posedge div_clk or negedge rst_n) begin
        if(!rst_n)
            cur_state <= st_idle;
        else
            cur_state <= next_state;
    end

    /**************************************************************
        状态机，主SD卡初始化配置
    ***************************************************************/
    always @(*) begin
        next_state = st_idle;
        case(cur_state)
            st_idle : begin
                //上电至少等待74个同步时钟周期
                if(poweron_cnt == POWER_ON_NUM)          //默认状态,上电等待SD卡稳定
                    next_state = st_send_cmd0;
                else
                    next_state = st_idle;
            end 
            st_send_cmd0 : begin                         //发送软件复位命令
                if(cmd_bit_cnt == 6'd47)
                    next_state = st_wait_cmd0;
                else
                    next_state = st_send_cmd0;    
            end               
            st_wait_cmd0 : begin                         //等待SD卡响应
                if(res_en) begin
                    if(res_data[47:40] == 8'h01) 
                        next_state = st_send_cmd8;
                    else
                        next_state = st_idle;
                end
                else if(over_time_en) 
                    next_state = st_idle;
                else
                    next_state = st_wait_cmd0;                                    
            end                                       
            st_send_cmd8 : begin                         //CMD8,检测SD卡是否适配
                if(res_en) begin
                    if(res_data[19:16] == 4'b0001)       
                        next_state = st_send_cmd55;
                    else
                        next_state = st_idle;
                end
                else
                    next_state = st_send_cmd8;            
            end
            st_send_cmd55 : begin  //切换应用相关命令
                if(res_en) begin 
                    if(res_data[47:40] == 8'h01)
                        next_state = st_send_acmd41;
                    else
                        next_state = st_send_cmd55;    
                end        
                else
                    next_state = st_send_cmd55;     
            end  
            st_send_acmd41 : begin                       //发送操作寄存器
                if(res_en) begin   
                    if(res_data[47:40] == 8'h00)
                        next_state = st_init_done;
                    else
                        next_state = st_send_cmd55;      //初始化未完成,重新发起 
                end
                else
                    next_state = st_send_acmd41;     
            end                
            st_init_done : next_state = st_init_done;    //初始化完成 
            default : next_state = st_idle;
        endcase
    end

    always @(posedge div_clk or negedge rst_n) begin
        if(!rst_n) begin
            sd_cs <= 1'b1;
            sd_mosi <= 1'b1;
            sd_init_done <= 1'b0;
            cmd_bit_cnt <= 6'd0;
            over_time_cnt <= 16'd0;
            over_time_en <= 1'b0;
        end else begin
            over_time_en <= 1'b0;
            case(cur_state)
                st_idle : begin                               //上电等待SD卡稳定
                    sd_cs <= 1'b1;
                    sd_mosi <= 1'b1;
                end     
                st_send_cmd0 : begin                          //发送CMD0软件复位命令
                    cmd_bit_cnt <= cmd_bit_cnt + 6'd1;        
                    sd_cs <= 1'b0;                            
                    sd_mosi <= CMD0[6'd47 - cmd_bit_cnt];
                    if(cmd_bit_cnt == 6'd47)                  
                        cmd_bit_cnt <= 6'd0;                  
                end      
                                
                st_wait_cmd0 : begin                          
                    sd_mosi <= 1'b1;             
                    if(res_en)                                //SD卡返回响应信号                 
                        sd_cs <= 1'b1;                                      
                    over_time_cnt <= over_time_cnt + 1'b1;
                    if(over_time_cnt == OVER_TIME_NUM - 1'b1) //SD卡响应超时,重新发送软件复位命令
                        over_time_en <= 1'b1; 
                    if(over_time_en)
                        over_time_cnt <= 16'd0;                                        
                end                                           
                st_send_cmd8 : begin                          //发送CMD8
                    if(cmd_bit_cnt<=6'd47) begin
                        cmd_bit_cnt <= cmd_bit_cnt + 6'd1;
                        sd_cs <= 1'b0;
                        sd_mosi <= CMD8[6'd47 - cmd_bit_cnt];       
                    end
                    else begin
                        sd_mosi <= 1'b1;
                        if(res_en) begin                      
                            sd_cs <= 1'b1;
                            cmd_bit_cnt <= 6'd0; 
                        end   
                    end                                                                   
                end 
                st_send_cmd55 : begin                         //发送CMD55
                    if(cmd_bit_cnt<=6'd47) begin
                        cmd_bit_cnt <= cmd_bit_cnt + 6'd1;
                        sd_cs <= 1'b0;
                        sd_mosi <= CMD55[6'd47 - cmd_bit_cnt];       
                    end
                    else begin
                        sd_mosi <= 1'b1;
                        if(res_en) begin                      
                            sd_cs <= 1'b1;
                            cmd_bit_cnt <= 6'd0;     
                        end        
                    end                                                                                    
                end
                st_send_acmd41 : begin                        //发送ACMD41
                    if(cmd_bit_cnt <= 6'd47) begin
                        cmd_bit_cnt <= cmd_bit_cnt + 6'd1;
                        sd_cs <= 1'b0;
                        sd_mosi <= ACMD41[6'd47 - cmd_bit_cnt];      
                    end
                    else begin
                        sd_mosi <= 1'b1;
                        if(res_en) begin                      
                            sd_cs <= 1'b1;
                            cmd_bit_cnt <= 6'd0;  
                        end        
                    end     
                end
                st_init_done : begin                          //初始化完成
                    sd_init_done <= 1'b1;
                    sd_cs <= 1'b1;
                    sd_mosi <= 1'b1;
                end
                default : begin
                    sd_cs <= 1'b1;
                    sd_mosi <= 1'b1;                
                end    
            endcase
        end
    end

endmodule