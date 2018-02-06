function CoreLog_CleanNCopy(filename,save_dir)
%% CoreLog_CleanNCopy
% This is a function to clean the core log and copy it to a different
% directory
%
% Cleaning (as of 11/28/17) means to remove unwanted messages related to
% displaying an image in the live window without the proper metadata. The
% error is:
% Error: MetaData did not contain ElapsedTime-ms field
%
%
% filename is the filename of the CoreLog
%
% save_dir is the directory where this CoreLog should be copied to

%% Cleaning
[~,fname,ext]=fileparts(filename);
filename=char(filename);

%read the core log
file_txt=fileread(filename);

%the current year, used for the start of each line in the micromanager log
logyear=file_txt(1:4);

start_str='Started sequence acquisition';
stop_str='Stopped sequence acquisition';
err_string='Error: MetaData did not contain ElapsedTime-ms field';


err_loc=strfind(file_txt,err_string);
year_loc=strfind(file_txt,logyear);
start_loc=strfind(file_txt,start_str);
stop_loc=strfind(file_txt,stop_str);

%start and stop indices to erase later
eraseindstemp=NaN(length(start_loc),2);
for ii=1:min(length(start_loc),length(stop_loc))
    [~,yrpos]=max(year_loc(year_loc<start_loc(ii)));
    eraseindstemp(ii,1)=year_loc(yrpos+1);
    eraseindstemp(ii,2)=max(year_loc(year_loc<stop_loc(ii)))-1;
    
    %make sure there is actually errors in the current block
    if ~any(err_loc>eraseindstemp(ii,1)&err_loc<eraseindstemp(ii,2))
         eraseindstemp(ii,1)=NaN;
         eraseindstemp(ii,2)=NaN;
    end
end

eraseinds=[0,0];
for ii=1:size(eraseindstemp,1)
    if ~any(isnan(eraseindstemp(ii,:)))
        eraseinds=[eraseinds;eraseindstemp(ii,:)];
    end
end
eraseinds(1,:)=[];

%go in reverse to preserve location values
for ii=fliplr(1:size(eraseinds,1))
   file_txt(eraseinds(ii,1):eraseinds(ii,2))=[];    
end

%get the year locations to put the newlines back
year_loc=strfind(file_txt,logyear);

%% Copying
fid=fopen([save_dir,filesep,fname,ext],'w');

for ii=1:(length(year_loc)-1)
   fprintf(fid,[strrep(file_txt(year_loc(ii):(year_loc(ii+1)-1)),'\','\\'),'\n']);    
end
fclose(fid);
end

