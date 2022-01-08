module vga_driver(
    input               vga_clk         ,
    input               sys_rst_n       ,                         
    output              vga_hs          ,
    output              vga_vs          ,
    output      [11:0]  vga_rgb         ,
    output              data_req        ,
    input       [11:0]  pixel_data      ,
    input               camera_show_mode,
    output reg  [18:0]  pixel_addr
);                             
                                                        
    /**************************************************************
        ��������
    ***************************************************************/ 
    parameter  H_SYNC   =  10'd96   ;   //��ͬ��
    parameter  H_BACK   =  10'd48   ;   //����ʾ����
    parameter  H_DISP   =  10'd640  ;   //����Ч����
    parameter  H_FRONT  =  10'd16   ;   //����ʾǰ��
    parameter  H_TOTAL  =  10'd800  ;   //��ɨ������

    parameter  V_SYNC   =  10'd2    ;   //��ͬ��
    parameter  V_BACK   =  10'd33   ;   //����ʾ����
    parameter  V_DISP   =  10'd480  ;   //����Ч����
    parameter  V_FRONT  =  10'd10   ;   //����ʾǰ��
    parameter  V_TOTAL  =  10'd525  ;   //��ɨ������
            
    /**************************************************************
        ������Ĵ�������
    ***************************************************************/                                  
    reg  [9:0]          hsync_cnt       ;
    reg  [9:0]          vsync_cnt       ;
    wire                vga_en          ;
    wire                data_req        ;


    /**************************************************************
        ��������
    ***************************************************************/    
    assign vga_hs  = (hsync_cnt <= H_SYNC - 1'b1) ? 1'b0 : 1'b1;    //��ͬ���ź�
    assign vga_vs  = (vsync_cnt <= V_SYNC - 1'b1) ? 1'b0 : 1'b1;    //��ͬ���ź�
    assign vga_en  = (((hsync_cnt >= H_SYNC+H_BACK) && (hsync_cnt < H_SYNC+H_BACK+H_DISP))
                    &&((vsync_cnt >= V_SYNC+V_BACK) && (vsync_cnt < V_SYNC+V_BACK+V_DISP)))
                    ?  1'b1 : 1'b0;                                 //VGA����ź�           
    assign vga_rgb = vga_en ? ((camera_show_mode &(hsync_cnt == 357 || hsync_cnt == 570 || vsync_cnt == 195 || vsync_cnt == 355)) ? 12'hfff : pixel_data) : 12'd0;                   //RGB444����ź�
    assign data_req = (((hsync_cnt >= H_SYNC+H_BACK-1'b1) && (hsync_cnt < H_SYNC+H_BACK+H_DISP-1'b1))
                    && ((vsync_cnt >= V_SYNC+V_BACK) && (vsync_cnt < V_SYNC+V_BACK+V_DISP)))
                    ?  1'b1 : 1'b0;                                 //���ص������ź�

    /**************************************************************
        ���ص��ַ�ź�
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
        ��ͬ��������
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
        ��ͬ��������
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