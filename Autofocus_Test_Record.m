%% Autofocus_Test_Record
% This script takes a series of movies at different z planes to provide
% data  to determine the optimal autofocus scoring metric.
%
% To use, start by manually focusing the microscope and waiting for drift
% to die down. Then run this script which will record the movies and
% positions. Then use the accompnying script Autofocus_Test_Analyze to try
% out different scoring metrics
%
%%%% Dependencies %%%%
% RecordMovie
%
%% Control Panel

% save directory
save_dir='~/Temp/';

% the number of frames to record
numframes=20;

% z search range in um
search_range = 5;
% number of z planes to check
numsteps = 30;

%% Setup
%the global micromanager structure
global mm

%%% the z positions to check %%%
%current z position
start_z=mm.core.getPosition(mm.core.getFocusDevice);

min_z=start_z-search_range/2;
max_z=start_z+search_range/2;

%set min_z to zero if negative
if min_z<0; min_z=0; end
% atm I don't know how to find the max z value of the FocusDevice, later a
% max limit should be set

%the z vector
zs=linspace(min_z,max_z,numsteps);

%prepping the save_dir
if save_dir(end)=='\'
   save_dir(end)=[];
end

%% Making the log file

% check if the directory exists, and if not create it
if exist(save_dir,'dir')~=7
    mkdir(save_dir)
end

%the log filename
log_fname=[save_dir,filesep,'Autofocus_Test_Log'];
%setting up the file
fid = fopen([log_fname,'.txt'], 'w');
fprintf(fid, 'Log File for Autofocus_Test_Record \r\n');
fprintf(fid,['Log written at ',char(datetime),'\r\n\r\n']);

fprintf(fid,'Filename \t z position (um) \r\n');

for ii=1:length(zs)
   mov_names{ii}=['mov_',num2str(ii)];
   
   fprintf(fid,[mov_names{ii},'\t ',num2str(zs(ii)),'\r\n']);
end
fclose(fid);


%% Record the data


%initialize waitbar
h1=waitbar(0);
set(h1,'Position',[481.5000 507 270 56.2500])
waitbar(0,h1,['Autofocusing from z = ',num2str(min_z,4),' \mum  to  ',...
    'z = ',num2str(max_z,4),' \mum']);

for ii=1:length(zs)
    %update the waitbar
    try;waitbar(ii/length(zs),h1);end
    
    %move to the z position
    SetZPosition(zs(ii))
    
    %current filename
    curfname=[save_dir,filesep,'mov_',num2str(ii)];
    
    %record the image(s)
    RecordMovie(curfname,numframes);
    
end
%closing the waitbar
try; close(h1); end



function SetZPosition(z_pos)
%the global micromanager structure
global mm

%name of focus device
focusDevice = mm.core.getFocusDevice;
%current z position
cur_z=mm.core.getPosition(mm.core.getFocusDevice);

%a loop to verify that the stage has moved to the position I asked it to
while round(cur_z,2)~=round(z_pos,2)
    %move the piezo
    mm.core.setPosition(focusDevice,z_pos);
    %wait for it to finish the move
    mm.core.waitForDevice(focusDevice);
    
    %current z position
    cur_z=mm.core.getPosition(mm.core.getFocusDevice);
end
end








