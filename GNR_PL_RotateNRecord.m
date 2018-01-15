function GNR_PL_RotateNRecord()
%% GNR_PL_RotateNRecord
% Function to record the PL from GNRs as a function of polarization
% rotation
%
%% Control Panel

% save directory
save_dir='E:\Microscope Images\Data\Ben\11_27_17\GNR_PL_Rot';

% the base of the name of the movie
nambase='GNRPLRotMov';

% the angles at which to measure
% angs=0:10:720;
angs=0:30:180;

% the number of frames to record
numframes=20;

%% setup the filenames and write the log file

%prepping the save_dir
if save_dir(end)=='\'
   save_dir(end)=[];
end

%the log filename
log_fname=[save_dir,filesep,'GNR_PL_Rot_log'];
%setting up the file
fid = fopen([log_fname,'.txt'], 'w');
fprintf(fid, 'Log File for GNR_PL_RotateNRecord \r\n');
fprintf(fid,['Log written at ',char(datetime),'\r\n\r\n']);

fprintf(fid,'Filename \t Stage Angle \r\n');

for ii=1:length(angs)
   mov_names{ii}=[nambase,'_',num2str(ii)];
   
   fprintf(fid,[mov_names{ii},'\t ',num2str(angs(ii)),'\r\n']);
end
fclose(fid);

%% initializing
% the global micromanager structure and rotation stage handle
global mm h_AXC

%home the stage
h_AXC.MoveHome(0,true);

for ii=1:length(angs)
   cur_ang=angs(ii);%the current angle
   
   %move the stage confidently
   MoveRotStage(cur_ang,true);
   
   %write to MM log
   mm.core.logMessage(['In GNR_PL_RotateNRecord, at ',num2str(cur_ang),...
       'degrees'])   
   
   RecordMovie([save_dir,filesep,mov_names{ii}],numframes);
    
end


end

