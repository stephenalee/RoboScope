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

filename=char(filename);

err_string='Error: MetaData did not contain ElapsedTime-ms field';

try
%     fid = fopen(filename, 'w');
    
    %read the core log
    file_txt=fileread(filename);
    start_loc=strfind(file_txt,err_string);
    
end

%% Copying

end

