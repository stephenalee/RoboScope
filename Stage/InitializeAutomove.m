function [mask,x,y,roi,fence,fidcent]=InitializeAutomove(roi,fence,thrshld,debug)
global mm
ROI=mm.core.getROI;
if mm.slm.getIsLiveModeOn
    livewason=true;
    mm.slm.setLiveMode(false);
else
    livewason=false;
end
mm.core.snapImage
fid=mm.core.getImage;
fid=reshape(fid,[ROI.width,ROI.height])';
fid=bpass(fid,1,5,10,5);
figure(66)
imshow(fid,[])
[y,x]=ginput(1); %Select fiduciary
%Make ROI for fiduciary
fidroi=fid(round(x)-roi:round(x)+roi,round(y)-roi:round(y)+roi);
%Make logical fence for fiduciary
mask=zeros(size(fidroi));
mask(ceil(end/2)-2*fence:ceil(end/2)+2*fence,ceil(end/2)-2*fence:ceil(end/2)+2*fence)=1;
%Check that fiduciary passes filtering
fidroi=logical(fidroi.*(fidroi>prctile(fidroi(fidroi>0),thrshld)));
fidcent=regionprops(fidroi,'centroid');
if size(fidcent,1)==1
    if mask(round(fidcent.Centroid(1,1)),round(fidcent.Centroid(1,2)))==1
        disp('Is centered')
    else
        disp('Is not centered')
    end
elseif size(fidcent,1)<1
    disp('No fiduciary. Lower threshold.')
elseif size(fidcent,1)>1
    disp('Too many particles. Raise threshold.')
end
close figure 66
if livewason
    mm.slm.setLiveMode(true);
end
if debug
    figure(67)
    imshow(fidroi,[])
end
end