function Program_Pump(h_pump,which_dir,volume)
%% Add_Dye
% This function programs the syringe pump to add or remove dye solution. To
% run this program on the pump use h_pump.sendcmd('RUN'); in Matlab
%
% h_pump is the handle of the pump returned from pumpsBen
%
% which_dir determines if the pump adds (infuses) or removes (withdraws)
% dye solution.
% To add (infuse)      set which_dir = 'add'
% To remove (withdraw) set which_dir = 'remove'
%
% volume is the amount of dye to be added or removed. Units are mL
%
% For programming command reference see the user manual at http://syringepump.com/download/NE-1000%20Syringe%20Pump%20User%20Manual.pdf
% pdf page 51 has a command appendix

% command to stop pump
% h_pump.sendcmd('STP');
%% Control panel

% how_much_dye=0.155;%in mL

%syringe diameter in mm
% syr_diam=8.585;%for 3 mL BD syringe
syr_diam=26.59;%for 60 mL BD syringe


%% set
%reset any previous programs on the pump
h_pump.sendcmd('*RESET');

% set the volume to be dispensed
h_pump.sendcmd('VOL ML');
h_pump.sendcmd(['VOL ',num2str(volume)]);

% set pump direction
if strcmp(which_dir,'add')
    % set pump direction to infuse liquid
    h_pump.sendcmd('DIR INF');
elseif strcmp(which_dir,'remove')
    % set pump direction to withdraw liquid
    h_pump.sendcmd('DIR WDR');
else
    error('Invalid direction. Please enter either ''add'' or ''remove''')
end

% set the syringe diameter
h_pump.sendcmd(['DIA ',num2str(syr_diam)]);

% set the pumping rate
% for 60 mL syringe the max rate is 28.32
h_pump.sendcmd('RAT 20 MM');

end
