# FPGA-DigitalCamera
Final Project for Digitial Logic (Fall 2021) , CS102109, Tongji University.

注意！使用SD卡进行照片传输时必须先初始化SD卡，并通过项目自带的工具先将8张照片转换成bin文件，把bin文件复制到SD卡目录下，否则会导致照片无法正常读取或者无法利用满8个槽位的空间！

Example Pictures:
- Capture Mode
![拍摄模式](demo/拍摄模式.jpg)
- Display Mode (Imported photo)
![电脑照片输入](demo/电脑照片输入.jpg)
- Display Mode (Local captured photo)
![拍摄照片显示](demo/拍摄照片显示.jpg)
- Display captured photo on computer
![照片给电脑显示](demo/照片给电脑显示.jpg)

Frame & RTL
- frame design:
![frame](demo/frame.png)
- RTL design:
![rtl](demo/rtl.png)

Basic board: Nexys4 DDR

Models used:

- Camera OV2460
- Bluetooth HC-06
- VGA display screen 480P 60Hz
- SD Card with SPI proxy

Designed functions:

- SD Card photo save&read
- Camera shooting

- Bluetooth remote control
- Extensive working indicators

Unsolved problems:

- Camera zoom , bright & contrast control.

Hope that someone who solved the problem can contact me or pull an issue. Thanks a lot :)

Reference Repository: <a herf="https://github.com/lllbbbyyy/FPGA-OV2640">FPGA-OV2640 </a>
