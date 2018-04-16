function tempcontrol(tcont,settemp)
decval=round((settemp/10)/0.00247);
register=floor(decval/256);
dataIn=(decval/256-register)*256;
writeRegister(tcont,register,dataIn)
end