function [a,tcont]=tempcontrolstartup(comnum)
a=arduino(comnum,'Uno','Libraries','I2C');
tcont=i2cdev(a,'0x60');
end