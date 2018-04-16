%% Autofocus_Test_Analyze
% This script analyzes a series of movies at different z planes to help
% determine the optimal autofocus score metric.
%
% To use, start running the accompnying script Autofocus_Test_Record. Use
% the same save directory (save_dir) and then try out different score
% metrics by altering the code in this script where it says "put score
% metric here".

%% Control Panel

% save directory
save_dir='\\Chem-biteen24\e\Microscope Images\Data\Ben\AF_Tests_1_16_18';

% number of frames to use.
% to use the entire movie set numframes=[];
numframes=3;

% try fitting?
do_fit = false;

% which fit function
% 111 - Gaussian with a flat base
% 222 - Gaussian with a sloped base
which_fitfun=111;

% What is the z psf length? Only required if doing fitting.
% zpsf is the approximate width of z psf in um. For a 700 nm emission with
% 1.4 NA zpsf = 0.3
zpsf = 0.3;

%% Read in log

%prepping the save_dir
if save_dir(end)=='\' || save_dir(end)=='/'
   save_dir(end)=[];
end

%the log filename
log_fname=[save_dir,filesep,'Autofocus_Test_Log.txt'];

logdata=importdata(log_fname);

% the z planes
zs=logdata.data;

% the filenames
fnames=strtrim(logdata.textdata(4:end));

%% Load data and calculate score metric

dataz=zeros(1,length(zs));%initialize the dataz vector
for ii=1:length(zs)
    % update loading here to lnly load the portion of the movie that will
    % be analyzed
    
    mov_io=matfile([save_dir,filesep,fnames{ii}],'Writable',false);
    
    if isempty(numframes)
        imgdata = double(mov_io.mov);
    else
        imgdata = double(mov_io.mov(:,:,1:numframes));
    end
    
    %%% put scoring metric here! %%%
    % put score in dataz vector as " dataz(ii) = your_code_here "
    dataz(ii)=std(imgdata(imgdata>prctile(imgdata(:),90)));
    
end

[~,max_pos]=max(dataz);
%% Fit it
if do_fit
    
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
    GoodFit=r_squared>0.65 && exitflag>0;
    
end

%% Plot it

%interpolate the fit result for a smoother plot
zsfine=linspace(min(zs),max(zs),200);

figure
plot(zs,dataz,'o','LineWidth',1.5','Color','b')
if do_fit
    hold on
    plot(zsfine,fitfun(fitted,zsfine),'LineWidth',2,'Color','r')
    title({['Fit max at z =',num2str(focus_z)],...
        ['R^2 = ',num2str(r_squared),'    GoodFit = ',num2str(GoodFit)]})
else
    title(['max score at z = ',num2str(zs(max_pos))])
end
xlabel('z position (\mum)')
ylabel('Score')
box on
axis tight
hold off

