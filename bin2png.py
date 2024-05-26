from PIL import Image
import random
import os

for e in range(0,16):
    if os.path.exists(str(e)+".bin"):
        binfile=open(str(e)+".bin", 'rb')
        c = Image.new("RGB",(640,480))
        for j in range (0,480):
            for i in range (0,640):
                data1 = binfile.read(1)
                data2 = binfile.read(1)
                c.putpixel([i,j], ((int.from_bytes(data1, byteorder='little') & 0x0f) << 4 , int.from_bytes(data2, byteorder='little') & 0xf0 ,(int.from_bytes(data2, byteorder='little') & 0x0f) << 4))
        c.show()
        c.save(str(e)+".png")