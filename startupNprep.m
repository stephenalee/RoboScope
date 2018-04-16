%% Control Panel
%where is micro-manager installed?
% mmroot='C:\Program Files\Micro-Manager-2.0beta';
mmroot='C:\Program Files\Micro-Manager-2018';
% mmroot='\\Chem-biteen24\c\Program Files\Micro-Manager-2.0beta';
%what is the config file that you want to use?
%don't think this is necessary
% config_file='C:\Program Files\Micro-Manager-2.0beta\MMConfig_demo.cfg';


% which devices?
use_Micromanager = true;
use_ThorlabsRotationStage = false;
use_SyringePump = false;
use_XY = false;
use_tempcontrol = false;
use_lasercontrol = false;
use_spectrometer = true;
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
%% Setup XY Stage
if use_XY
    global xycont;
    xySN = 65864236; % put in the serial number of the hardware
    fpos    = get(0,'DefaultFigurePosition'); % figure default position
    fpos(3) = 650; % figure window size;Width
    fpos(4) = 450; % Height
    fig_xy = figure('Position', fpos,'Menu','None','Name','APT GUI');
    % Create ActiveX Controller
    xycont = actxcontrol('APTPZMOTOR.APTPZMotorCtrl.1',[20 20 600 400 ], fig_xy);
    % Initialize
    % Start Control
    % Set the Serial Number
    set(xycont,'HWSerialNum', xySN);
    % Indentify the device
    xycont.StartCtrl;
    pause(5); % waiting for the GUI to load up;
    % To move use h.MoveJog(Channel,Direction)  Channel=Channel-1;
    % Direction(1==up, 2==dn)
    % To select jog size use h.SetJogStepSize(Channel,Stepsize)
end

%% Set up temperature control
if use_tempcontrol
    global deviceObj
    deviceObj=setupTDS;
    global tcont
    [~,tcont]=tempcontrolstartup('COM16'); %Change COM to appropriate value
end
%% Setup pumps
if use_SyringePump
    global h_pump_silver h_pump_red
    
    %red pump removes dye
    h_pump_red=pumpsyr('COM13')
    % silver pump adds dye
    h_pump_silver=pumpsyr('COM12')   
    
    %program the pumps
    Program_Pump(h_pump_red,'remove',0.250)
    Program_Pump(h_pump_silver,'add',0.200)
    
    % to run the programs on the pumps use the commands:
%     h_pump_red.sendcmd('RUN'); %remove dye
%     h_pump_silver.sendcmd('RUN'); %add dye
    
end

%% Set up the laser
if use_lasercontrol==1
    global laser laseron laserpower
    laser=Sapphire('COM14');
    setlaser(laser,'<',0);
    setlaser(laser,'E',0);
    laseron=setlaser(laser,'?L'); %See if laser is on
    if strcmp('1',laseron)
    laserpower=setlaser(laser,'?P'); %If laser is on, what's the power
    else
        laseron=setlaser(laser,'L',1);
    setlaser(laser,'P',5); %If laser is off, set the power to 5mw but keep it off
    laserpower=5;
    end
end

%% Set up the laser
if use_spectrometer==1
    global spect
    spect=Spectrometer('COM9');
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


