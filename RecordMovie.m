function mov=RecordMovie(filename,numframes)
% RecordMovie is a function written by BPI to record a movie using
% micromanager.
%
% outputs a movie mov. *Note if you don't want mov stored in the workspace
% (potentially taking up a lot of memory) as ans, then call this function
% as [~]=RecordMovie(mm.core,filename,numframes)
%
% filename is the filename of the movie to be saved, if no movie is to be
% saved then put a [] there instead
%
% numframes is the number of frames to record

%% initializing
%the global micromanager structure
global mm

% file info
try
    [pathstr,fname] = fileparts(filename);
catch
    fname='frames';
end

mm.core.logMessage(['Running RecordMovie, saving ',filename])

%ROI with ROI.width & ROI.height
ROI=mm.core.getROI;

% checking live mode
if mm.slm.getIsLiveModeOn
    livewason=true;
    mm.slm.setLiveMode(false);
else
    livewason=false;
end

%intialize matrix
mov=zeros(ROI.height,ROI.width,numframes);
%change to correct image type
try
    %see if there is a last image available
    lastimg=mm.core.getLastImage;
    imtype=class(lastimg);
    mov=eval([imtype,'(mov)']);
catch
    try
        %if not take a new image
        mm.core.snapImage;
        lastimg=mm.core.getImage;
        imtype=class(lastimg);
        mov=eval([imtype,'(mov)']);
    catch
        %guess that it's a uint16 type
        mov=uint16(mov);
    end
end

%% acquiring
%initialize waitbar
h1=waitbar(0);
set(h1,'Position',[481.5000 507 270 56.2500])
set(findall(h1,'type','text'),'Interpreter','none');
waitbar(0,h1,['Recording ',fname]);

% start the acquisition (and importantly the circular buffer)
% inputs ar: number of frames, interval between frames, Boolean re stopping
% on overflow
mm.core.startSequenceAcquisition(numframes, 0, false);

tic;%for debugging purposes
%initialize the frame counter
ii = 1;
%loop through until the the number of sequence is done
while mm.core.isSequenceRunning || mm.core.getRemainingImageCount>0    
    if mm.core.getRemainingImageCount>0       
        %grab & remove the next image from the circular buffer
        img = mm.core.popNextImage;
                
        %get the time for debugging purposes
        times(ii)=toc;
        
        %NOTE This line mm.slm.displayImage(img); is causing the error 
        % [IFO,App] Error: MetaData did not contain ElapsedTime-ms field 
        % to appear in the corelog 4 times everytime it's called as-is. ATM
        % I'm not sure how to fix this.
        
        %update the image in the Snap/Live Window
        mm.slm.displayImage(img);       
              
        %put the image into the array
        mov(:,:,ii)=reshape(img,[ROI.width,ROI.height])';        
               
        %update the counter
        ii=ii+1;
        %update the waitbar
        try;waitbar(ii/numframes,h1);end        
    end
end
%stop the acquisition
mm.core.stopSequenceAcquisition;

%closing the waitbar
try; close(h1); end

%turn live mode back on if it was on initially
if livewason
    mm.slm.setLiveMode(true);
end

%debugging
% diff(times)

%% save it
%if there is no file name given don't do this
if ~isempty(filename)
    % check if either file exists already and if so rename to append _2nd
    while exist([pathstr,filesep,fname,'.tif'],'file')==2 || exist([pathstr,filesep,fname,'.mat'],'file')==2
        fname=[fname,'_2nd'];
    end
    
    %save the log file
    Ben_LogFile([pathstr,filesep,fname],numframes);
    
    %save it as a .mat file
    save([pathstr,filesep,fname],'mov');
    %save as a tiff stack
    options.message=false;
    % *note there might be a datatype problem here, if the movie isn't being
    % saved as a tiff stack check that it's an appropriate datatype
    saveastiff(mov,[pathstr,filesep,fname,'.tif'],options);
end

end
