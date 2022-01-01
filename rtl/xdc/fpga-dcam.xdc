set_property PACKAGE_PIN E3 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets sys_clk]

set_property PACKAGE_PIN V10 [get_ports sys_rst]
set_property IOSTANDARD LVCMOS33 [get_ports sys_rst]

set_property IOSTANDARD LVCMOS33 [get_ports {sd_data[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sd_data[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sd_data[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sd_data[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports sd_cmd]
set_property IOSTANDARD LVCMOS33 [get_ports sd_reset]
set_property IOSTANDARD LVCMOS33 [get_ports sd_sck]
set_property IOSTANDARD LVCMOS33 [get_ports sd_cd]
set_property PACKAGE_PIN D2 [get_ports {sd_data[3]}]
set_property PACKAGE_PIN F1 [get_ports {sd_data[2]}]
set_property PACKAGE_PIN E1 [get_ports {sd_data[1]}]
set_property PACKAGE_PIN C2 [get_ports {sd_data[0]}]
set_property PACKAGE_PIN B1 [get_ports sd_sck]
set_property PACKAGE_PIN C1 [get_ports sd_cmd]
set_property PACKAGE_PIN E2 [get_ports sd_reset]
set_property PACKAGE_PIN A1 [get_ports sd_cd]

set_property PACKAGE_PIN   C17  [get_ports camera_pwdn]
set_property IOSTANDARD LVCMOS33 [get_ports camera_pwdn]
set_property PACKAGE_PIN   D17  [get_ports camera_reset]
set_property IOSTANDARD LVCMOS33 [get_ports camera_reset]
set_property PACKAGE_PIN   G16  [get_ports camera_href]
set_property IOSTANDARD LVCMOS33 [get_ports camera_href]
set_property PACKAGE_PIN   F13  [get_ports camera_pclk]
set_property IOSTANDARD LVCMOS33 [get_ports camera_pclk]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets camera_pclk]
set_property PACKAGE_PIN   F16  [get_ports camera_xclk]
set_property IOSTANDARD LVCMOS33 [get_ports camera_xclk]
set_property PACKAGE_PIN   G13  [get_ports camera_vsync]
set_property IOSTANDARD LVCMOS33 [get_ports camera_vsync]

set_property PACKAGE_PIN   D18  [get_ports camera_data[0]]
set_property IOSTANDARD LVCMOS33 [get_ports camera_data[0]]
set_property PACKAGE_PIN   E18  [get_ports camera_data[2]]
set_property IOSTANDARD LVCMOS33 [get_ports camera_data[2]]
set_property PACKAGE_PIN   G17  [get_ports camera_data[4]]
set_property IOSTANDARD LVCMOS33 [get_ports camera_data[4]]
set_property PACKAGE_PIN   E17  [get_ports camera_data[1]]
set_property IOSTANDARD LVCMOS33 [get_ports camera_data[1]]
set_property PACKAGE_PIN   F18  [get_ports camera_data[3]]
set_property IOSTANDARD LVCMOS33 [get_ports camera_data[3]]
set_property PACKAGE_PIN   G18  [get_ports camera_data[5]]
set_property IOSTANDARD LVCMOS33 [get_ports camera_data[5]]
set_property PACKAGE_PIN   D14  [get_ports camera_data[6]]
set_property IOSTANDARD LVCMOS33 [get_ports camera_data[6]] 
set_property PACKAGE_PIN   E16  [get_ports camera_data[7]]
set_property IOSTANDARD LVCMOS33 [get_ports camera_data[7]]

set_property PACKAGE_PIN   H16  [get_ports camera_sio_c]
set_property IOSTANDARD LVCMOS33 [get_ports camera_sio_c]
set_property PACKAGE_PIN   H14  [get_ports camera_sio_d]
set_property IOSTANDARD LVCMOS33 [get_ports camera_sio_d]
set_property PULLUP TRUE [get_ports camera_sio_d]

set_property PACKAGE_PIN A3 [get_ports {vga_rgb[8]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_rgb[8]}]
set_property PACKAGE_PIN B4 [get_ports {vga_rgb[9]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_rgb[9]}]
set_property PACKAGE_PIN C5 [get_ports {vga_rgb[10]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_rgb[10]}]
set_property PACKAGE_PIN A4 [get_ports {vga_rgb[11]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_rgb[11]}]

set_property PACKAGE_PIN C6 [get_ports {vga_rgb[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_rgb[4]}]
set_property PACKAGE_PIN A5 [get_ports {vga_rgb[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_rgb[5]}]
set_property PACKAGE_PIN B6 [get_ports {vga_rgb[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_rgb[6]}]
set_property PACKAGE_PIN A6 [get_ports {vga_rgb[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_rgb[7]}]

set_property PACKAGE_PIN B7 [get_ports {vga_rgb[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_rgb[0]}]
set_property PACKAGE_PIN C7 [get_ports {vga_rgb[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_rgb[1]}]
set_property PACKAGE_PIN D7 [get_ports {vga_rgb[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_rgb[2]}]
set_property PACKAGE_PIN D8 [get_ports {vga_rgb[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_rgb[3]}]

set_property PACKAGE_PIN B12 [get_ports vga_vsync]
set_property IOSTANDARD LVCMOS33 [get_ports vga_vsync]
set_property PACKAGE_PIN B11 [get_ports vga_hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vga_hsync]

set_property PACKAGE_PIN J15 [get_ports {key[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[0]}]
set_property PACKAGE_PIN L16 [get_ports {key[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[1]}]
set_property PACKAGE_PIN M13 [get_ports {key[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[2]}]
set_property PACKAGE_PIN R15 [get_ports {key[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[3]}]
set_property PACKAGE_PIN R17 [get_ports {key[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[4]}]
set_property PACKAGE_PIN T18 [get_ports {key[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[5]}]
set_property PACKAGE_PIN U18 [get_ports {key[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[6]}]
set_property PACKAGE_PIN R13 [get_ports {key[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key[7]}]
set_property PACKAGE_PIN H17 [get_ports {led[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
set_property PACKAGE_PIN K15 [get_ports {led[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[1]}]
set_property PACKAGE_PIN J13 [get_ports {led[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[2]}]
set_property PACKAGE_PIN N14 [get_ports {led[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[3]}]
set_property PACKAGE_PIN R18 [get_ports {led[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[4]}]
set_property PACKAGE_PIN V17 [get_ports {led[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[5]}]
set_property PACKAGE_PIN U17 [get_ports {led[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[6]}]
set_property PACKAGE_PIN U16 [get_ports {led[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[7]}]

set_property IOSTANDARD LVCMOS33 [get_ports {seg_ctl[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ctl[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ctl[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ctl[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ctl[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ctl[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ctl[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ctl[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ena[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ena[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ena[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ena[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ena[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ena[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ena[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg_ena[0]}]
set_property PACKAGE_PIN T10 [get_ports {seg_ctl[0]}]
set_property PACKAGE_PIN R10 [get_ports {seg_ctl[1]}]
set_property PACKAGE_PIN K16 [get_ports {seg_ctl[2]}]
set_property PACKAGE_PIN K13 [get_ports {seg_ctl[3]}]
set_property PACKAGE_PIN P15 [get_ports {seg_ctl[4]}]
set_property PACKAGE_PIN T11 [get_ports {seg_ctl[5]}]
set_property PACKAGE_PIN L18 [get_ports {seg_ctl[6]}]
set_property PACKAGE_PIN H15 [get_ports {seg_ctl[7]}]
set_property PACKAGE_PIN J17 [get_ports {seg_ena[0]}]
set_property PACKAGE_PIN J18 [get_ports {seg_ena[1]}]
set_property PACKAGE_PIN T9 [get_ports {seg_ena[2]}]
set_property PACKAGE_PIN J14 [get_ports {seg_ena[3]}]
set_property PACKAGE_PIN P14 [get_ports {seg_ena[4]}]
set_property PACKAGE_PIN T14 [get_ports {seg_ena[5]}]
set_property PACKAGE_PIN K2 [get_ports {seg_ena[6]}]
set_property PACKAGE_PIN U13 [get_ports {seg_ena[7]}]

set_property PACKAGE_PIN G6 [get_ports bluetooth_txd]
set_property IOSTANDARD LVCMOS33 [get_ports bluetooth_txd]
set_property PACKAGE_PIN J2 [get_ports bluetooth_rxd]
set_property IOSTANDARD LVCMOS33 [get_ports bluetooth_rxd]