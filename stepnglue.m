function mov=stepnglue(filename,minwl,maxwl,overlap,grating)
%% stepnglue is a function for recording spectra for regions larger than a single image can record.
% minwl is the starting wavelength, maxwl is the ending wavelength in nanometers. 
% spacing is the output "resolution" of in nanometers. 
% overlap is % spectral overlap between frames
% grating is the grating to use for imaging. 'fine' for 600g/mm or 'coarse' 150g/mm.

%% initializing
%the global micromanager structure
global mm
%The global spectrometer structure
global spect
% file info
try
    [pathstr,fname] = fileparts(filename);
catch
    fname='frames';
end
if strcmp(grating,'coarse')
sendcmd(spect,'GRATING',3);
dispersion=0.338;
grooves=150;
elseif strcmp(grating,'fine')
sendcmd(spect,'GRATING',2);
dispersion=0.079;
grooves=600;
end
resp=sendcmd(spect,'?GRATING');
while ~contains(resp,'GRATING')
    resp=sendcmd(spect,'?GRATING');
end
numframes=ceil((maxwl-minwl)/dispersion/(512*(100-overlap)/100));
wlcents=linspace(minwl,maxwl,numframes);
mm.core.logMessage(['Running StepNGlue, saving ',filename])

%ROI with ROI.width & ROI.height
ROI=mm.core.getROI;
mm.core.setROI(0,ROI.y,512,ROI.height) 
% checking live mode
if mm.slm.getIsLiveModeOn
    livewason=true;
    mm.slm.setLiveMode(false);
else
    livewason=false;
end

%intialize matrix
mov=zeros(ROI.height+1,512,numframes);
for ii=1:numframes
    beta=asind(10^-6*1*grooves*wlcents(ii)/2/cosd(15.15/2))+15.15/2;
    ldisp=10^6*cosd(beta)*cosd(beta-1.38)^2/300/grooves;
mov(1,:,ii)=fliplr(linspace(-255,256,512)*ldisp*0.016+wlcents(ii));
end
%% acquiring
%initialize waitbar
h1=waitbar(0);
set(h1,'Position',[481.5000 507 270 56.2500])
set(findall(h1,'type','text'),'Interpreter','none');
waitbar(0,h1,['Recording ',fname]);
mm.core.clearCircularBuffer
for ii=1:numframes
    sendcmd(spect,'GOTO',wlcents(ii));
    resp=sendcmd(spect,'MONO-?DONE');
    while ~contains(resp,'1')
        resp=sendcmd(spect,'MONO-?DONE');
    end 
    mm.core.snapImage;
    img=mm.core.getImage;
    mov(2:end,:,ii)=reshape(img,[ROI.height,512])';
    try;waitbar(ii/numframes,h1);end   
end
%closing the waitbar
try; close(h1); end

spectrum=mov(:,:,1);
for ii=2:numframes
spectrum=[spectrum,mov(:,:,ii)];
end
pcolor(spectrum(1,:),linspace(1,size(spectrum,1)-1,size(spectrum,1)-1),spectrum(2:end,:));
xlim([minwl,maxwl])
shading flat
xlabel('Wavelength (nm)')
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
    Stephen_LogFile([pathstr,filesep,fname],numframes);
    
    %save it as a .mat file, using version 7.3 to ensure partial loading is
    %available
    save([pathstr,filesep,fname],'mov','spectrum','-v7.3');
    %save as a tiff stack
    % options.message=false;
    % *note there might be a datatype problem here, if the movie isn't being
    % saved as a tiff stack check that it's an appropriate datatype
%     saveastiff(mov,[pathstr,filesep,fname,'.tif'],options);
end

end
