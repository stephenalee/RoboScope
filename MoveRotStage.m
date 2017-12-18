function MoveRotStage(angle,confident_move)
% MoveRotStage is a function written by BPI to move the rotation stage
%
% angle is the angle in degrees that the stage should be moved to
%
% confident_move is a Boolean determining whether or not to very carefully
% ensure that the stage has reached the desired angle. default is false

%precision of comparison
ang_prec=3;%two decimal places must be equal

if nargin<2;confident_move=false;end

global h_AXC

%% Inital Move
% put the angle into mod 360
angle=mod(angle,360);

% *note the 0 in all the commands indicates the channel, 0 means channel 1
% and 1 means channel 2 (dumb I know)

h_AXC.SetAbsMovePos(0,angle);
% move to the position.
% *note the true indicates that Matlab should wait until the move has
% successfully been completed
h_AXC.MoveAbsolute(0,true);

%% Carefully check that it's arrived at angle
if confident_move    
    %pause to give it a moment to get to the right position
    pause(4);
    %get the current angle
    cur_ang=h_AXC.GetPosition_Position(0);
    
    while round(cur_ang,ang_prec)~=round(angle,ang_prec)
        warning([num2str(round(cur_ang,ang_prec)),' ~= ',num2str(round(angle,ang_prec))])
        warning(['Rotation stage failed to accurately move to ',num2str(angle),...
            'deg, retrying'])
       
        
        %try homing the stage and then moving
        h_AXC.MoveHome(0,true);
        
        h_AXC.SetAbsMovePos(0,angle);
        h_AXC.MoveAbsolute(0,true);
        
        %get the current angle
        pause(4);
        cur_ang=h_AXC.GetPosition_Position(0);        
    end
end

end

