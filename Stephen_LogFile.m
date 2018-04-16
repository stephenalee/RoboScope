function Stephen_LogFile(mov_filename,numframes)
%% Ben_LogFile
% Writes a custom log file for a particular movie
%
% mov_filename is the filename of the movie for which this the log file
%
% numframes is the number of frames of the movie

%% initializing

global mm h_AXC deviceObj laser

%the log filename
log_fname=[mov_filename,'_log'];


fid = fopen([log_fname,'.txt'], 'w');
fprintf(fid, ['Log File for ',strrep(mov_filename,'\','\\'),'\r\n']);
fprintf(fid,['Log written at ',char(datetime),'\r\n\r\n']);

%% Writing the log
fprintf(fid,['Number of frames: ',num2str(numframes),'\r\n']);
try
    cur_ang=h_AXC.GetPosition_Position(0);
    fprintf(fid,['Rotation stage at: ',num2str(cur_ang),' degrees \r\n']);
catch
    fprintf(fid,'No successful communication with rotation stage \r\n');
end

try
    objtemp=round(get(deviceObj.Measurement(1),'Value')+0.164,1);
    fprintf(fid,['Objective temp at: ',num2str(objtemp),' degrees C \r\n']);
catch
    fprintf(fid,'No successful communication with osciliscope channel 1 \r\n');
end
try
    samptemp=round(get(deviceObj.Measurement(2),'Value'),1);
    fprintf(fid,['Sample temp at: ',num2str(samptemp),' degrees C \r\n']);
catch
    fprintf(fid,'No successful communication with osciliscope channel 2 \r\n');
end
try
    laserpower=setlaser(laser,'?P');
    fprintf(fid,['Laser power set to ',laserpower(16:20),' mW \r\n']);
catch
    fprintf(fid,'No successful communication with laser \r\n');
end

%print the ROI info
 fprintf(fid,['ROI = ',strrep(char(mm.core.getROI),'java.awt.Rectangle',''),'\r\n']);

% '\r\n']);
%%% the camera loop %%%
try   
    camdev=mm.core.getCameraDevice;
    camprops=mm.core.getDevicePropertyNames(camdev);
    
    fprintf(fid,['\r\n Listing device properties for camera ',char(camdev),'\r\n']);
    
    ii=1;
    %loop until an error occurs
    while true
        propval=mm.core.getProperty(camdev,camprops.get(ii));
        
        fprintf(fid,[char(camprops.get(ii)),' ',char(propval),'\r\n']);
        ii=ii+1;
    end
    
catch
    fprintf(fid,'End of Camera properties or some error reading them \r\n\r\n');
end

%%% the stage loop %%%
try   
    stagdev=mm.core.getFocusDevice;
    stagprops=mm.core.getDevicePropertyNames(stagdev);
    
    fprintf(fid,['\r\n Listing device properties for stage ',char(stagdev),'\r\n']);
    
    ii=1;
    %loop until an error occurs
    while true
        propval=mm.core.getProperty(stagdev,stagprops.get(ii));
        
        fprintf(fid,[char(stagprops.get(ii)),' ',char(propval),'\r\n']);
        ii=ii+1;
    end
    
catch
    fprintf(fid,'End of Stage properties or some error reading them \r\n\r\n');
end

fclose(fid);

end

