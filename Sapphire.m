classdef Sapphire < handle
    % Class for controlling Coherent Sapphire Lasers with RS-232 connectivity.
    %
    % Usage is:
    % Laser_handle = pumpsyr('COM7')
    % where COM7 is the com port that the laser is connected to. Then send
    % commands to the laser as:
    % laser_handle.interface(cmd_str)
    % where cmd_str the command string, as explained in the user manual at http://syringepump.com/download/NE-1000%20Syringe%20Pump%20User%20Manual.pdf
    %
    %
    % Based on arduino.m master/slave interface for Matlab by ...
    % Giampiero Campa.
    %
    % Based on:
    % Author: Lloyd Ung
    % created: 2012-04-15
    % last modified: 2012-10-11
    %
    % Modified significantly by Benjamin P Isaacoff (BPI)
    % last modification Dec 2017
    %
    % Adapted for Coherent lasers with RS-232 connectivity by Stephen A Lee
    % 
    
    %% Class Constants
    properties (Constant = true)
        % Serial link parameters
        SapphireConfig = struct('BaudRate',19200,'DataBits',8,...
            'FlowControl','none','Parity','none','StopBits',1,...
            'Terminator','CR/LF');
        
        % Constants
        serialWaitTime = 1; % units of seconds
    end
    
    %% Class properties
    % Private class properties
    %     properties (SetAccess = private, GetAccess = private)
    properties
        % Serial handle
        serialHandle = [];
    end
    
    %% Class Methods
    methods
        % Class creator - initializes serial link.
        function obj = Sapphire(port)
            % Check input string
            if ~ischar(port)
                error(['The input argument must be a string, e.g. '...
                    '''COM8'' ']);
            end
            
            % check if we are already connected
            if isa(obj.serialHandle,'serial') && ...
                    isvalid(obj.serialHandle) && ...
                    strcmpi(get(obj.serialHandle,'Status'),'open')
                disp('Desired port is not available.');
                return;
            end
            
            % check whether serial port is currently used by MATLAB
            if ~isempty(instrfind({'Port'},{port}))
                disp(['The port ' port ' is already used by MATLAB']);
                error(['Port ' port ' already used by MATLAB']);
            end
            
            % Choose the pump type
            serialConfig = obj.SapphireConfig;
            
            % define serial object and configure according to pumps.
            obj.serialHandle = serial(port,'BaudRate',...
                serialConfig.BaudRate,'DataBits',serialConfig.DataBits,...
                'FlowControl',serialConfig.FlowControl,...
                'Parity',serialConfig.Parity,...
                'StopBits',serialConfig.StopBits,...
                'Terminator',serialConfig.Terminator);
            
            % Connect port
            try
                fopen(obj.serialHandle);
            catch ME
                disp(ME.message)
                delete(obj);
                %                 obj = [];
                error(['Could not open port: ' port]);
            end
            
            pause(obj.serialWaitTime);
        end
        
        % delete laser object, closing serial
        function delete(obj)
            % Terminate the serial link.
            % if it is a serial, valid and open then close it
            if isa(obj.serialHandle,'serial') && ...
                    isvalid(obj.serialHandle) && ...
                    strcmpi(get(obj.serialHandle,'Status'),'open')
                fclose(obj.serialHandle);
            end
            
            % if it's an object delete it
            if isobject(obj.serialHandle)
                delete(obj.serialHandle);
            end
        end
        
        % Method for communicating with the laser.
        function rString = setlaser(obj,writeString,value)
            % Add the address, if necessary.
            if nargin > 2 
                % Set number to 
                if value==1 || value==0
                    numString=num2str(value,'%d');
                else
                numString = num2str(value,'%.1f');
                end
                % Concatenate address with write string.
                writeString = [writeString '=' numString];
            end
            
            % Print the command.
            fprintf(obj.serialHandle,writeString);
            
            % Wait for bytes to appear at the port.
            pause(obj.serialWaitTime);
            rString=char('Sapphire Values');
            % Read the bytes at the port.
            while get(obj.serialHandle,'BytesAvailable')>0
            readString= fscanf(obj.serialHandle,'%s',...
                get(obj.serialHandle,'BytesAvailable'));
            rString=[rString,readString];
            end
        end
    end
end