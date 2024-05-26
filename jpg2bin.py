from PIL import Image
import random
import os

for e in range(0,16):
    if os.path.exists(str(e)+".jpg"):
        im=Image.open(str(e)+".jpg")
        width,height = im.size
        if(width != 640 or height != 480):
            im = im.resize([640,480])
            width,height = im.size
        fh=open(str(e)+".bin",'wb')
        for i in range(height):
            for j in range(width): 
                color=im.getpixel((j,i))
                data1 = color[0] >> 4
                data2 = ((color[1] >> 4) << 4) + (color[2] >> 4)
                fh.write(data1.to_bytes(1,'little'))
                fh.write(data2.to_bytes(1,'little'))
        fh.close()