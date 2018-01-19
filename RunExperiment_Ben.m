function RunExperiment_Ben()
%% RunExperiment
% Function to run my experiment!

%% Control Panel

% save directory
save_dir='E:\Microscope Images\Data\Ben\1_17_18';

% the base of the name of the movie
nambase='mov';

% the angles at which to measure
angs=0:5:90;

% scramble angle order?
rand_order=true;

% record in an endless loop
inf_loop=true;

% the number of frames to record for each movie
numframes=4000;

% after how many movies should new dye solution be added
addDyeafter=2;

% autofocus options
AF_everymov=true;%autofocus before every movie
AF_afterdye=false;%autofocus only after dye is added

AF_smartsearch=true;% use the smart search functionality in Autofocus_wrapper

%% Initialize

global mm
global h_pump_silver h_pump_red

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
while keep_it_runnin
    %possibly scramble the angle order
    if rand_order
        angs=angs(randperm(length(angs)));
    end
    %write to screen
    disp(char(datetime))
    disp(['Starting a group of movies with angle order :',mat2str(angs)])
    %write to MM log
    mm.core.logMessage(['Starting a group of movies with angle order :',mat2str(angs)]);
    
    for ii=1:length(angs)
        % increment the movie counter
        mov_ctr=mov_ctr+1;
        
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
        
        cur_ang=angs(ii);%the current angle
        
        %move the stage confidently
        MoveRotStage(cur_ang,true);
        
        %possibly run autofocus
        if AF_everymov || mov_ctr==1
            disp(char(datetime))
            disp('Autofocusing')
%             Autofocus_wrapper(AF_smartsearch);
            Autofocus_wrapper_single(AF_smartsearch);
        end
        
        %write to MM log
        mm.core.logMessage(['In RunExperiment, at ',num2str(cur_ang),...
            'degrees'])
        %write to screen
        disp(char(datetime))
        disp(['Recording movie ',nambase,'_',num2str(mov_ctr,'%03.f'),...
            '   at ',num2str(cur_ang)])
        
        %Record the movie!
        RecordMovie([save_dir,filesep,nambase,'_',num2str(mov_ctr,'%03.f')],numframes);
        
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
    end
    
    if  ~inf_loop
        keep_it_runnin=false;
    end
end















end

