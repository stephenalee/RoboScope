%% Control Panel
%where is micro-manager installed?
% mmroot='C:\Program Files\Micro-Manager-2.0beta';
mmroot='C:\Program Files\Micro-Manager';
% mmroot='\\Chem-biteen24\c\Program Files\Micro-Manager-2.0beta';
%what is the config file that you want to use?
%don't think this is necessary
% config_file='C:\Program Files\Micro-Manager-2.0beta\MMConfig_demo.cfg';


% which devices?
use_Micromanager = false;
use_ThorlabsRotationStage = false;
use_SyringePump = true;


%% import & startup%get current directory and add it to the path
if use_Micromanager
    curdir=pwd;
    addpath(genpath(curdir));
    %change to micro-manager directory and add it to path
    addpath(genpath(mmroot));
    cd(mmroot);
    
    %debugging
    % cd(mmroot)
    import mmcorj.*;
    import org.micromanager.*;
    
    %create global variables
    global mm
    mm = struct([]);
    
    %startup micro-manager
    mm(1).studio=StartMMStudio;
    mm.core = mm.studio.getCore;
    mm.gui = mm.studio.getInstance;
    mm.acq = mm.studio.getAcquisitionEngine;
    mm.slm = mm.studio.getSnapLiveManager;
    
    cd(curdir)
end
%% Setup rotation stage
if use_ThorlabsRotationStage
    global h_AXC
    
    %the serial number for the stage
    SN=83842738;
    
    %get figure handle
    fig_AXC_h=figure;
    % start the activeX control
    h_AXC=actxcontrol('MGMOTOR.MGMotorCtrl.1',fig_AXC_h.Position,fig_AXC_h);
    % set the serial number
    set(h_AXC,'HWSerialNum', SN);
    % start controlling it
    h_AXC.StartCtrl;
    
    % *note the 0 in all the commands indicates the channel, 0 means channel 1
    % and 1 means channel 2 (dumb I know)
    % home the stage
    h_AXC.MoveHome(0,true);
end

%% Setup pumps
if use_SyringePump
    global h_pump_silver h_pump_red
    
    %red pump removes dye
    h_pump_red=pumpsyr('COM13')
    % silver pump adds dye
    h_pump_silver=pumpsyr('COM12')   
    
    %program the pumps
    Program_Pump(h_pump_red,'remove',0.150)
    Program_Pump(h_pump_silver,'add',0.155)
    
    % to run the programs on the pumps use the commands:
%     h_pump_red.sendcmd('RUN'); %remove dye
%     h_pump_silver.sendcmd('RUN'); %add dye
    
end

%% Some test commands
if 0
    
    %get the position
    % h_AXC.GetAbsMovePos_AbsPos(0)
    h_AXC.GetPosition_Position(0)
    
    %%%move to an example angle degrees%%%
    ex_ang=95;
    %first set where the move will go to
    h_AXC.SetAbsMovePos(0,ex_ang);
    % move to the position.
    % *note the true indicates that Matlab should wait until the move has
    % successfully been completed
    h_AXC.MoveAbsolute(0,true);
    
    
    %% Test
    % RecordTiffStack(core,filename,numframes)
    RecordMovie('E:\Microscope Images\Data\Ben\temp\test\asd.tif',50);
    RecordMovie([],10);
    
    
end


