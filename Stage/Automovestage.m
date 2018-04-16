function Automovestage(roi,mask,fence,x,y,fidcent,debug)
global mm
global xycont
ROI=mm.core.getROI;
if mm.slm.getIsLiveModeOn
    livewason=true;
    mm.slm.setLiveMode(false);
else
    livewason=false;
end
tries=1;
while tries<50
    mm.core.snapImage;
    img=mm.core.getImage;
    mm.slm.displayImage(img);
    img = reshape(img,[ROI.width,ROI.height])';
    fidroi=img(round(x)-roi:round(x)+roi,round(y)-roi:round(y)+roi,1);%Get current frame from mm
    fidroi=bpass(fidroi,1,5,10,5);
    fidroi=logical(fidroi.*(fidroi>prctile(fidroi(fidroi>0),98)));
    fidcent1=regionprops(fidroi,'centroid');
    if size(fidcent1,1)==1
            rud=fidcent.Centroid(1,2)-fidcent1.Centroid(1,2); rlr=fidcent.Centroid(1,1)-fidcent1.Centroid(1,1);
        if mask(round(fidcent1.Centroid(1,1)),round(fidcent1.Centroid(1,2)))==1
            disp('Particle Centered')
            break
        elseif abs(rud)>2*fence && abs(rlr)>2*fence
            if sign(rud)==-1 && sign(rlr)==1
                xycont.MoveJog(0,1); 
                pause(.005)
                xycont.MoveJog(1,1); 
            elseif sign(rud)==1 && sign(rlr)==1
                xycont.MoveJog(0,2);
                pause(.005)
                xycont.MoveJog(1,1); 
            elseif sign(rud)==-1 && sign(rlr)==-1
                xycont.MoveJog(0,1); 
                pause(.005)
                xycont.MoveJog(1,2);
            elseif sign(rud)==1 && sign(rlr)==-1
                xycont.MoveJog(0,2); 
                pause(.005)
                xycont.MoveJog(1,2);
            end
        elseif abs(rud)>2*fence && abs(rlr)<=2*fence
            if sign(rud)==-1
                xycont.MoveJog(0,1);
            else
                xycont.MoveJog(0,2);
            end
        elseif abs(rud)<=2*fence && abs(rlr)>2*fence
            if sign(rlr)==1
                xycont.MoveJog(1,1);
            else
                xycont.MoveJog(1,2);
            end
        end
    end
    tries=tries+1;
    if debug
figure
imshow(fidroi,[]);
    end
end
if tries>=50
    disp('No particle found or too many')
end
if livewason
    mm.slm.setLiveMode(true);
end
end