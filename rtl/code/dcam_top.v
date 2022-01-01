module camera_top(
    input               sys_clk         ,
    input               sys_rst         ,

    //摄像头
    output              camera_sio_c    ,   
    inout               camera_sio_d    ,   
    output              camera_reset    ,   
    output              camera_pwdn     ,   
    output              camera_xclk     ,   
    input               camera_pclk     ,
    input               camera_href     ,
    input               camera_vsync    ,   
    input  [7:0]        camera_data     ,

    //按键（测试用）
    input  [7:0]        key             ,
    output [7:0]        led             ,

    //七段数码管
    output [7:0]        seg_ena         ,
    output [7:0]        seg_ctl         ,

    //VGA
    output [11:0]       vga_rgb         ,
    output              vga_hsync       ,
    output              vga_vsync       ,

    //蓝牙
    input               bluetooth_rxd   ,
    input               bluetooth_txd   ,

    //SD卡
    input               sd_cd           ,
    output              sd_reset        ,
    output              sd_sck          ,
    output              sd_cmd          ,
    inout  [3:0]        sd_data         
);

    /**************************************************************
    线网与寄存器定义
    ***************************************************************/
    //分频时钟
    wire                clk_sd_50m          ;      //SD卡写入时钟， 50mhz
    wire                clk_sd_50m_180deg   ;      //SD卡读取时钟， 50mhz
    wire                clk_vga_24m         ;      //VGA写入时钟， 24mhz
    wire                clk_sccb_init_25m   ;      //SCCB配置初始化时钟，25mhz

    //SPI交互
    wire                sd_clk              ;      //SPI时钟
    wire                sd_cs               ;      //SPI片选数据线
    wire                sd_mosi             ;      //SPI发送数据线
    wire                sd_miso             ;      //SPI接受数据线

    //SD卡写操作
    wire                wr_start_en         ;      //开始写SD卡数据信号
    wire    [31:0]      wr_sec_addr         ;      //写数据扇区地址    
    wire    [15:0]      wr_data             ;      //写数据            
    wire                rd_start_en         ;      //开始写SD卡数据信号
    wire    [31:0]      rd_sec_addr         ;      //读数据扇区地址  

   //SD卡读操作
    wire                wr_busy             ;      //写数据忙信号
    wire                wr_req              ;      //写数据请求信号
    wire                rd_busy             ;      //读忙信号
    wire                rd_val_en           ;      //数据读取有效使能信号
    wire    [15:0]      rd_val_data         ;      //读数据
    wire                sd_init_done        ;      //SD卡初始化完成信号

    //蓝牙模式选择
    wire                photo_out_ena       ;      //照片输出使能
    wire    [3:0]       select_photo_no     ;      //照片位选择地址
    wire                get_photo_mode      ;      //读取模式选线
    wire                caught_photo_mode   ;      //摄影模式选线
    wire                camera_show_mode    ;      //取景模式选线
    wire                camera_init_done    ;      //摄像头初始化完成使能
    //照片读写地址
    wire    [18:0]      sd_wr_ram_addr      ;      //SD卡写入地址
    wire    [11:0]      photo_out_data      ;      //照片读出信息
    wire    [18:0]      photo_out_position  ;      //照片读出位置
    wire    [18:0]      sd_rd_ram_addr      ;      //照片写入位置

    //RAM读写地址控制
    wire    [11:0]      ram_data            ;       //摄像机写数据
    wire    [18:0]      ram_addr            ;       //摄像机写地址
    wire    [11:0]      vga_rd_data         ;       //VGA读数据
    wire    [18:0]      rd_addr             ;       //VGA读地址
    wire    [18:0]      baddr               ;       //RAM端口B选择地址
    wire    [11:0]      mem_douta           ;       //RAM端口A输出信号
    wire                wea_enable          ;       //RAM端口A读写选择信号
    wire                wr_en               ;       //缓存写有效信号
    wire    [11:0]      vga_color_in        ;       //vga颜色输入信号
    wire    [11:0]      doutb               ;       //RAM端口B输出信号

    /**************************************************************
    线网连接
    ***************************************************************/
    //SD转SPI
    assign sd_reset = 0;
    assign sd_data[1] = 1;
    assign sd_data[2] = 1;
    assign sd_data[3] = sd_cs;
    assign sd_cmd = sd_mosi;
    assign sd_sck = sd_clk;
    assign sd_miso = sd_data[0];
    
    //LED状态指示灯连接
    assign led[0] = camera_show_mode;
    assign led[1] = caught_photo_mode;
    assign led[2] = get_photo_mode;
    assign led[3] = sd_init_done;
    assign led[4] = camera_init_done;
    assign led[5] = ~sd_cd;

    //双口RAM地址选线
    assign wr_data = {4'b0, mem_douta};
    assign baddr = (rd_val_en ? sd_rd_ram_addr : ( caught_photo_mode ? sd_wr_ram_addr : rd_addr));
    assign mem_douta = doutb;
    assign vga_rd_data = doutb;
    assign wea_enable = wr_en & camera_show_mode;
    assign vga_color_in = (caught_photo_mode ? 12'hf00 : vga_rd_data);

    /**************************************************************
    实例化分频器
    ***************************************************************/
    clk_wiz_0 clk_wiz_div(
        .clk_in1            (sys_clk)               ,
        .clk_out1           (clk_vga_24m)           ,
        .clk_out2           (clk_sccb_init_25m)     ,
        .clk_out3           (clk_sd_50m)            ,
        .clk_out4           (clk_sd_50m_180deg)
    );

    /**************************************************************
    实例化摄像头初始化模块
    ***************************************************************/
    ov2640_sccb_cfg_init ov2640_sccb_cfg_init_0(
        .clk                (clk_sccb_init_25m)     ,
        .sio_c              (camera_sio_c)          ,
        .sio_d              (camera_sio_d)          ,
        .reset              (camera_reset)          ,
        .pwdn               (camera_pwdn)           ,  
        .rst                (sys_rst)               ,
        .camera_init_done   (camera_init_done)      ,
        .xclk               (camera_xclk)
    );

    /**************************************************************
    实例化摄像头数据传输模块
    ***************************************************************/
    ov2640_data_driver ov2640_data_driver_0(
        .rst                (sys_rst)               ,
        .pclk               (camera_pclk)           ,
        .href               (camera_href)           ,
        .vsync              (camera_vsync)          ,
        .data_in            (camera_data)           ,
        .data_out           (ram_data)              ,
        .wr_en              (wr_en)                 ,
        .ram_out_addr       (ram_addr)
    );

    /**************************************************************
    实例化RAM模块
    ***************************************************************/
    blk_mem_gen_0 ram_0(
        .clka               (sys_clk)               ,
        .ena                (1'b1)                  ,
        .wea                (wea_enable)            ,
        .addra              (ram_addr)              ,
        .dina               (ram_data)              ,
        .clkb               (sys_clk)               ,
        .enb                (1'b1)                  ,
        .addrb              (baddr)                 ,
        .dinb               (rd_val_data[11:0])     ,
        .doutb              (doutb)                 ,
        .web                (rd_val_en)
    );

    /**************************************************************
    实例化VGA输出模块
    ***************************************************************/
    vga_driver vga(
        .vga_clk            (clk_vga_24m)           ,
        .sys_rst_n          (~sys_rst)              ,
        .pixel_data         (vga_color_in)          ,
        .pixel_addr         (rd_addr)               ,
        .vga_hs             (vga_hsync)             ,
        .vga_vs             (vga_vsync)             ,
        .vga_rgb            (vga_rgb)            
    );

    
    /**************************************************************
    实例化蓝牙状态选择模块
    ***************************************************************/
    bluetooth_mode_control bluetooth_mode_control_0(
        .sys_clk            (sys_clk)               ,
        .sys_rst            (sys_rst)               ,
        .bluetooth_rxd      (bluetooth_txd)         ,
        .get_photo_mode     (get_photo_mode)        ,
        .caught_photo_mode  (caught_photo_mode)     ,
        .camera_show_mode   (camera_show_mode)      ,
        .select_photo_no    (select_photo_no)
    );

    /**************************************************************
    实例化7段数码管状态显示模块
    ***************************************************************/
    display7 display7_0( 
		.clk                (sys_clk)               ,
		.led1               (sd_wr_ram_addr[3:0])   ,
		.led2               (sd_wr_ram_addr[7:4])   ,
		.led3               (sd_wr_ram_addr[11:8])  ,
		.led4               (sd_wr_ram_addr[15:12]) ,
		.led5               ({1'b0,sd_wr_ram_addr[18:16]}),
		.led6               (4'b0)                  ,
		.led7               (4'b0)                  ,
		.led8               (select_photo_no)       ,
		.ena                (seg_ena)               ,
		.ctl                (seg_ctl)
	);

    /**************************************************************
    实例化SD卡控制模块
    ***************************************************************/
    sd_ctrl sd_ctrl_0(
        .clk_ref            (clk_sd_50m)            ,
        .clk_ref_180deg     (clk_sd_50m_180deg)     ,
        .rst_n              (~sys_rst)              ,
        .sd_miso            (sd_miso)               ,
        .sd_clk             (sd_clk)                ,   
        .sd_cs              (sd_cs)                 ,
        .sd_mosi            (sd_mosi)               ,
        .wr_start_en        (wr_start_en)           ,
        .wr_sec_addr        (wr_sec_addr)           ,
        .wr_data            (wr_data)               ,
        .wr_busy            (wr_busy)               ,
        .wr_req             (wr_req)                ,
        .rd_start_en        (rd_start_en)           ,
        .rd_sec_addr        (rd_sec_addr)           ,
        .rd_busy            (rd_busy)               ,
        .rd_val_en          (rd_val_en)             ,
        .rd_val_data        (rd_val_data)           ,    
        .sd_init_done       (sd_init_done)          
    );

    /**************************************************************
    实例化SD卡读取照片模块
    ***************************************************************/
    sd_read_photo sd_read_photo_0(
        .clk                (clk_sd_50m)            ,
        .get_photo_mode     (get_photo_mode)        ,
        .rd_start_en        (rd_start_en)           ,
        .select_photo_no    (select_photo_no)       ,
        .rd_busy            (rd_busy)               ,
        .rd_val_en          (rd_val_en)             ,
        .sd_rd_ram_addr     (sd_rd_ram_addr)        ,
        .rd_sec_addr        (rd_sec_addr)
    );

    /**************************************************************
    实例化SD卡写入照片模块
    ***************************************************************/
    sd_write_photo sd_write_photo_0(
        .clk                (clk_sd_50m)            ,
        .caught_photo_mode  (caught_photo_mode)     ,
        .select_photo_no    (select_photo_no)       ,
        .wr_start_en        (wr_start_en)           ,
        .wr_sec_addr        (wr_sec_addr)           ,
        .wr_busy            (wr_busy)               ,
        .wr_req             (wr_req)                ,
        .sd_wr_ram_addr     (sd_wr_ram_addr)
    );
endmodule
