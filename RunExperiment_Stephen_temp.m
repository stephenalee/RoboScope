function RunExperiment_Stephen_temp()
%% RunExperiment
% Function to run my experiment!

%% Control Panel

% save directory
save_dir='E:\Microscope Images\Data\Stephen\2018-03-09\data';

% the base of the name of the movie
nambase='mov';

% the temperatures at which to measure
temps=26:0.4:56;
% Set the laser intensities
laseintense=5:2.5:50;
% scramble temperature order?
rand_order=false;

% How many loops to record
loops=2;

% the number of frames to record for each movie
numframes=300;

% after how many movies should new dye solution be added
addDyeafter=inf;

% autofocus options
AF_everymov=false;%autofocus before every movie
AF_afterdye=false;%autofocus only after dye is added

AF_smartsearch=true;% use the smart search functionality in Autofocus_wrapper

Keep_Centered=true;% use automove stage to keep fiduciary centered

%% Initialize

global mm
global laser laseron
global h_pump_silver h_pump_red
global tcont
global deviceObj
global xycont
xycont.SetJogStepSize(0,10);
xycont.SetJogStepSize(1,10);
laseron=setlaser(laser,'?L');
if strcmp(laseron,'0')
    setlaser(laser,'L',1)
end
if Keep_Centered
    global mask xpos ypos roi fence fidcent
    [mask,xpos,ypos,roi,fence,fidcent]=InitializeAutomove(20,2,99,0);
end
% check if the directory exists, and if not create it
if exist(save_dir,'dir')~=7
    mkdir(save_dir)
end

% setting up the pause button
h_pause=figure(97);
btn = uicontrol('Style','checkbox','String','Pause after movie','FontSize',40,'Position',[20,20,1000,200]);
%reset the checkbox
btn.Value=false;

%% Run it
keep_it_runnin=true;

mov_ctr=0;%the movie number counter
dye_ctr=0;%the counter for adding dye
for kk=1:loops
    %possibly scramble the angle order
    if rand_order
        temps=temps(randperm(length(temps)));
    end
    %write to screen
    disp(char(datetime))
    disp(['Starting a group of movies with temp order :',mat2str(temps)])
    %write to MM log
    mm.core.logMessage(['Starting a group of movies with temp order :',mat2str(temps)]);
    mov_ctr=mov_ctr+1;        % increment the movie counter
    for ii=1:length(temps)
        int_ctr=1;
        for jj=1:length(laseintense)
            cur_intens=laseintense(jj);
            setlaser(laser,'P',cur_intens);
            %check if it's time to add dye
            if dye_ctr==addDyeafter
                disp(char(datetime))
                disp('Adding dye')
                h_pump_red.sendcmd('RUN'); %remove dye
                h_pump_silver.sendcmd('RUN'); %add dye
                
                dye_ctr=0;
                %possibly run autofocus
                if AF_afterdye
                    disp(char(datetime))
                    disp('Autofocusing')
                    %                 Autofocus_wrapper(AF_smartsearch);
                    Autofocus_wrapper_single(AF_smartsearch);
                end
            end
            
            cur_temp=temps(ii);%the current temp
            tempcontrol(tcont,cur_temp);
            while cur_temp<round(get(deviceObj.Measurement(1), 'Value')-1,1) || cur_temp>round(get(deviceObj.Measurement(1), 'Value')+1,1)
                disp(['Temp=',num2str(round(get(deviceObj.Measurement(1), 'Value')+0.164,1)),'^oC',...
                    ' Target=',num2str(cur_temp),'^oC']);
                Autofocus_wrapper_single(AF_smartsearch);
                Automovestage(roi,mask,fence,xpos,ypos,fidcent,0)
            end
            
            %possibly run autofocus
            if AF_everymov || int_ctr==1
                disp(char(datetime))
                disp('Autofocusing')
                %             Autofocus_wrapper(AF_smartsearch);
                Autofocus_wrapper_single(AF_smartsearch);
                Automovestage(roi,mask,fence,xpos,ypos,fidcent,0)
            end
            
            %write to MM log
            mm.core.logMessage(['In RunExperiment, at ',num2str(cur_temp),...
                'degrees'])
            %write to screen
            disp(char(datetime))
            disp(['Recording movie.',' Temp=',num2str(round(get(deviceObj.Measurement(1), 'Value')+0.164,1)),'^oC',...
                ' Target=',num2str(cur_temp),'^oC',' Intensity = ',...
                num2str(cur_intens,'%0.1f')])
            
            %Record the movie!
            RecordMovie([save_dir,filesep,nambase,'_T',num2str(floor(cur_temp),'%3.f'),'p',num2str((cur_temp-floor(cur_temp))*10,'%1.f'),'_I',num2str(floor(cur_intens),'%3.f'),'p',num2str((cur_intens-floor(cur_intens))*10,'%1.f'),'_',num2str(mov_ctr,'%03.f')],numframes);
            
            %increment the dye counter
            dye_ctr=dye_ctr+1;
            % check the pause button
            try
                if btn.Value
                    keyboard %pause the program using the debug
                    %reset the checkbox
                    btn.Value=false;
                end
            catch
                % setting up the pause button
                h_pause=figure(97);
                btn = uicontrol('Style','checkbox','String','Pause after movie','FontSize',40,'Position',[20,20,1000,200]);
                %reset the checkbox
                btn.Value=false;
            end
            int_ctr=int_ctr+1;
        end
    end
    temps=fliplr(temps);
end















end

