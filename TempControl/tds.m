%% Instrument Connection
function tds(fname,deviceObj)
% Execute device object function(s).
% set(deviceObj.Measurement(1), 'MeasurementType', 'crms');
groupObj1=get(deviceObj,'Trigger');
m=matfile(fname,'Writable',true);
    m.temp=0;
    m.t=0;
f=figure('Visible','off');
btn = uicontrol('Style', 'checkbox', 'String', 'end',...
        'Position', [50 0 150 100]);  
f.Visible = 'on';
screen=get(0,'ScreenSize');
set(f,'Position',[screen(3)/2,screen(4)/2,150,100])
drawnow
tic
while btn.Value==0
    if strcmp(groupObj1.State,'trigger')
        temp=get(deviceObj.Measurement(2), 'Value');
        t=toc;
        m.temp(end+1,:)=temp;
        m.t(1,end+1)=t;
    else
        pause(0.02)
    end
end
end