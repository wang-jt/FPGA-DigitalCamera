`timescale 1ps/1ps

module sd_read_photo_tb();
    reg clk;
    reg get_photo_mode;
    wire [31:0] rd_sec_addr;
    wire rd_start_en;
    reg rd_val_en ;
    reg rd_busy;
    wire [18:0] sd_rd_ram_addr;
    sd_read_photo sd_read_photo_0(
        .clk            (clk),
        .get_photo_mode (get_photo_mode),
        .rd_sec_addr    (rd_sec_addr),
        .rd_busy        (rd_busy),
        .rd_start_en    (rd_start_en),
        .rd_val_en      (rd_val_en),
        .sd_rd_ram_addr (sd_rd_ram_addr)
    );

    initial begin
        clk = 0;
        rd_busy = 0;
        rd_val_en = 0;
        get_photo_mode = 0;
        #50 get_photo_mode = 1;
        #500 get_photo_mode = 0;
        #50 get_photo_mode = 1;
    end
    always #20 rd_val_en = ~rd_val_en;
    always #1 clk = ~clk;
endmodule

module sd_write_photo_tb();
    reg clk;
    reg [3:0] select_photo_no;
    reg caught_photo_mode;
    reg wr_req;
    reg wr_busy;
    wire wr_start_en;
    wire [31:0] wr_sec_addr;
    wire [18:0] sd_wr_ram_addr;

    sd_write_photo sd_write_photo_0(
        .clk                (clk),
        .select_photo_no    (select_photo_no),
        .caught_photo_mode  (caught_photo_mode),
        .wr_req             (wr_req),
        .wr_busy            (wr_busy),
        .wr_start_en        (wr_start_en),
        .wr_sec_addr        (wr_sec_addr),
        .sd_wr_ram_addr     (sd_wr_ram_addr)
    );
    initial begin
        caught_photo_mode = 0;
        select_photo_no = 0;
        clk = 0;
        wr_busy = 0;
        wr_req = 0;
        #50;
        caught_photo_mode = 1;
        #500;
        caught_photo_mode = 0;
    end
    always #10 wr_req = ~wr_req;
    always #1 clk = ~clk;
endmodule