function Ben_LogFile(mov_filename,numframes)
%% Ben_LogFile
% Writes a custom log file for a particular movie
%
% mov_filename is the filename of the movie for which this the log file
%
% numframes is the number of frames of the movie

%% initializing

global mm h_AXC

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

