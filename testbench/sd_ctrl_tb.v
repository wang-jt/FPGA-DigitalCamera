`timescale 1ps/1ps

module sd_ctrl_tb();
    reg clk_ref, clk_ref_180deg, rst_n;
    reg sd_miso;
    wire sd_clk;
    wire sd_cs, sd_mosi;
    reg wr_start_en;
    reg [31:0] wr_sec_addr;
    reg [15:0] wr_data;
    wire wr_busy, wr_req,rd_busy,rd_val_en;
    reg rd_start_en;
    reg [31:0] rd_sec_addr;
    wire [15:0] rd_val_data;
    wire sd_init_done;
    sd_ctrl sd_ctrl_0(
        .clk_ref        (clk_ref),
        .clk_ref_180deg (clk_ref_180deg),
        .rst_n          (rst_n),
        .sd_miso        (sd_miso),
        .sd_clk         (sd_clk),
        .sd_cs          (sd_cs),
        .sd_mosi        (sd_mosi),
        .wr_start_en    (wr_start_en),
        .wr_sec_addr    (wr_sec_addr),
        .wr_data        (wr_data),
        .wr_busy        (wr_busy),
        .wr_req         (wr_req),
        .rd_start_en    (rd_start_en),
        .rd_sec_addr    (rd_sec_addr),
        .rd_busy        (rd_busy),
        .rd_val_en      (rd_val_en),
        .rd_val_data    (rd_val_data),
        .sd_init_done   (sd_init_done)
    );
    initial begin
        clk_ref = 0;
        clk_ref_180deg= 1;
        rst_n = 0 ;
        sd_miso = 1;
        wr_start_en = 0;
        wr_sec_addr = 0;
        wr_data = 0;
        rd_start_en = 0;
        rd_sec_addr = 0;
        #10 rst_n = 1;
    end

    always #1 clk_ref = ~clk_ref;
    always #1 clk_ref_180deg = ~clk_ref_180deg;

    always @(posedge clk_ref or negedge rst_n) begin
    if(!rst_n) begin
        sd_init_done_d0 <= 1'b0;
        sd_init_done_d1 <= 1'b0;
    end
    else begin
        sd_init_done_d0 <= sd_init_done;
        sd_init_done_d1 <= sd_init_done_d0;
    end        
end

always @(posedge clk_ref or negedge rst_n) begin
    if(!rst_n) begin
        wr_start_en <= 1'b0;
        wr_sec_addr <= 32'd0;
    end    
    else begin
        if(pos_init_done) begin
            wr_start_en <= 1'b1;
            wr_sec_addr <= 32'd2000;
        end    
        else
            wr_start_en <= 1'b0;
    end    
end 

always @(posedge clk_ref or negedge rst_n) begin
    if(!rst_n)
        wr_data_t <= 16'b0;
    else if(wr_req) 
        wr_data_t <= wr_data_t + 16'b1;
end

always @(posedge clk_ref or negedge rst_n) begin
    if(!rst_n) begin
        wr_busy_d0 <= 1'b0;
        wr_busy_d1 <= 1'b0;
    end    
    else begin
        wr_busy_d0 <= wr_busy;
        wr_busy_d1 <= wr_busy_d0;
    end
end 

always @(posedge clk_ref or negedge rst_n) begin
    if(!rst_n) begin
        rd_start_en <= 1'b0;
        rd_sec_addr <= 32'd0;    
    end
    else begin
        if(neg_wr_busy) begin
            rd_start_en <= 1'b1;
            rd_sec_addr <= 32'd2000;
        end   
        else
            rd_start_en <= 1'b0;          
    end    
end    

always @(posedge clk_ref or negedge rst_n) begin
    if(!rst_n) begin
        rd_comp_data <= 16'd0;
        rd_right_cnt <= 9'd0;
    end     
    else begin
        if(rd_val_en) begin
            rd_comp_data <= rd_comp_data + 16'b1;
            if(rd_val_data == rd_comp_data)
                rd_right_cnt <= rd_right_cnt + 9'd1;  
        end    
    end        
end

endmodule