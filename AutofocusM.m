function [GoodFit,focus_z] = AutofocusM(search_range,numsteps,zpsf,numframes,plot_results,which_fitfun)
%% AutofocusM
% This script focus the microscope by measuring a focus score for a series
% of movies (or images in numframes is set to 1).
%
%%%% Inputs %%%%
%
% search_range is the z range in um that the algorithm will search over.
%
% numsteps is the number of z planes that will be measured
%
% numframes is the number of frames to record at each z plane. Default is 1
%
% zpsf is the approximate width of z psf in um. For a 700 nm emission with
% 1.4 NA zpsf = 0.3
%
% plot_results is a Boolean determining whether or not to plot the results.
% Default is true
%
% which_fitfun is a code asking which function to be fit to to precisely
% determine the optimally focused z plane. Codes are:
% 111 - Gaussian with a flat base
% 222 - Gaussian with a sloped base
% Default is 111
%
%%%% Outputs %%%%
% GoodFit is a Boolean indicating whether or not the fit to the focus score
% measurements was good or not
%
% focus_z is the optimally focused z plane returned in um
%
%%%% Dependencies %%%%
% RecordMovie

if nargin<4;numframes=1;end
if nargin<5;plot_results=true;end
if nargin<6;which_fitfun=111;end

%% Setup
%the global micromanager structure
global mm

% checking live mode
if mm.slm.getIsLiveModeOn
    livewason=true;
    mm.slm.setLiveMode(false);
else
    livewason=false;
end

% the fit functions
if which_fitfun==111
    fitfun=@(coefs,x)coefs(1)*exp(-(x-coefs(2)).^2./coefs(3))+coefs(4);
elseif which_fitfun==222
    fitfun=@(coefs,x)coefs(1)*exp(-(x-coefs(2)).^2./coefs(3))+coefs(4)+coefs(5).*x;
else
    Error('Invalid fit function code, please see the comments in Autofocus for valid codes')
end

%%% the z positions to check %%%
%current z position
start_z=mm.core.getPosition(mm.core.getFocusDevice);

min_z=start_z-search_range/2;
max_z=start_z+search_range/2;

%set min_z to zero if negative
if min_z<0; min_z=0; end
% atm I don't know how to find the max z value of the FocusDevice, later
% a max limit should be set

%the z vector
zs=linspace(min_z,max_z,numsteps);

%% Measure the data & calculate the score
try
    %write to MM log
    mm.core.logMessage(['Running AutofocusBen from z = ',num2str(min_z,4),' um  to  ',...
        'z = ',num2str(max_z,4),' um']);
    
    %initialize waitbar
    h1=waitbar(0);
    set(h1,'Position',[481.5000 507 270 56.2500])
    waitbar(0,h1,['Autofocusing from z = ',num2str(min_z,4),' \mum  to  ',...
        'z = ',num2str(max_z,4),' \mum']);
    
    dataz=zeros(1,length(zs));%initialize the dataz vector
    for ii=1:length(zs)
        %update the waitbar
        try;waitbar(ii/length(zs),h1);end
        
        %move to the z position
        SetZPosition(zs(ii))
        
        %record the image(s)
        %         imgdata=double(RecordMovie([],numframes));
        imgdata=AF_record(numframes);
        
        %%% autofocus score metric! %%%
        dataz(ii)=std(imgdata(imgdata>prctile(imgdata(:),90)));
    end
    %closing the waitbar
    try; close(h1); end
    
    %turn live mode back on if it was on initially
    if livewason
        mm.slm.setLiveMode(true);
    end
    
    % remove up to one outlier, by finding the datapoint that is the
    % farthest from a moving mean with window of 5 points
    outlyinds=isoutlier(dataz,'movmean',5);
    if any(outlyinds)        
        distmov=mean(abs(dataz-movmean(dataz,5)));
        [~,outlyin]=max(distmov);
        try
            dataz(outlyin)=mean([dataz(outlyin-1),dataz(outlyin+1)]);
        catch
            try
                dataz(outlyin)= dataz(outlyin-1);
            catch
                dataz(outlyin)= dataz(outlyin+1);
            end
        end
        warning('Outlier removed from autofocus score data')
    end
    
    
    
    %% fit to a Gaussian
    [~,max_pos]=max(dataz);
    %fit start and bounds
    if which_fitfun==111
        starts=[range(dataz),zs(max_pos),zpsf,min(dataz)];
        lb=[range(dataz),min(zs),.1*zpsf,0.75*min(dataz)];
        ub=[1.5*range(dataz),max(zs),2*zpsf,max(dataz)];
    elseif which_fitfun==222
        %line calculation
        m=median(dataz(1:4)-dataz((end-3):end))/mean(zs(1:4)-zs((end-3):end));
        b=median(dataz([1:4,(end-3):end])-m*zs([1:4,(end-3):end]));
        starts=[range(dataz),zs(max_pos),zpsf,b,m];
        %bounds assuming that m & b are positive
        lb=[0.1*range(dataz),min(zs),.1*zpsf,0.1*b,0.1*m];
        ub=[1.5*range(dataz),max(zs),2*zpsf,2*b,2*m];
        % either the slope or intercept are negative then switch the
        % upper and lower bounds
        if b<0
            tmp_bound=lb(4);
            lb(4)=ub(4);
            ub(4)=tmp_bound;
        end
        if m<0
            tmp_bound=lb(5);
            lb(5)=ub(5);
            ub(5)=tmp_bound;
        end
    end
    
    %fitting command
    opts = optimset('Display','off');%turning off the fit display to the cmd window
    [fitted,resnorm,~,exitflag]=lsqcurvefit(fitfun,starts,zs,dataz,lb,ub,opts);
    
    focus_z=fitted(2);
    
    % calculate the R^2 value
    r_squared=1-resnorm/sum((dataz-mean(dataz)).^2);
    
    % determine whether or not it's a good fit
    GoodFit=r_squared>0.7 && exitflag>0 && ~any(fitted==lb|fitted==ub);
    
    %plot the fit results
    if plot_results
        %interpolate the fit result for a smoother plot
        zsfine=linspace(min(zs),max(zs),200);
        
        figure(99)
        plot(zs,dataz,'o','LineWidth',1.5','Color','b')
        hold on
        plot(zsfine,fitfun(fitted,zsfine),'LineWidth',2,'Color','r')
        xlabel('z position (\mum)')
        ylabel('Score')
        %             title(['Fit max at z =',num2str(fitted(2))])
        title({['Fit max at z =',num2str(focus_z)],...
            ['R^2 = ',num2str(r_squared),'    GoodFit = ',num2str(GoodFit)]})
        box on
        axis tight
        hold off
    end
    
    %% move the optimal z plane
    % if not a good fit then stay at the original position
    if ~GoodFit
        focus_z=start_z;
    end
    % move it
    SetZPosition(focus_z);
catch
    SetZPosition(start_z);
    
    focus_z=start_z;
    GoodFit=false;
    
    warning('Autfocus Error: Function Failed to Finish')
end

end


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


function mov=AF_record(numframes)
%this is just a simple fast function to get the image data without the
%bells and whistles of RecordMovie

%the global micromanager structure
global mm

%ROI with ROI.width & ROI.height
ROI=mm.core.getROI;
mov=zeros(ROI.height,ROI.width,numframes);

for ii=1:numframes
    mm.core.snapImage;
    img=double(mm.core.getImage);
    %note for current iteration I'm just using a list of pixel values, and
    %don't actually need images. I just put this in here for possible
    %future expansions. Regardless, even for 512x512 the reshaping is super
    %fast, so I'm not worried about it.
    mov(:,:,ii)=reshape(img,[ROI.height,ROI.width]);
end

end















