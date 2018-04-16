classdef pumpsyr < handle
    % Class for controlling NewEra syringe pumps with RS-232 connectivity.
    %
    % Usage is:
    % pump_handle = pumpsyr('COM7')
    % where COM7 is the com port that the pump is connected to. Then send
    % commands to the pump as:
    % pump_handle.interface(cmd_str)
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
    
    %% Class Constants
    properties (Constant = true)
        % Serial link parameters
        newEraSerialConfig = struct('BaudRate',19200,'DataBits',8,...
            'FlowControl','none','Parity','none','StopBits',1,...
            'Terminator','CR');
        
        % Constants
        serialWaitTime = 0.5; % units of seconds
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
        function obj = pumpsyr(port)
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
            serialConfig = obj.newEraSerialConfig;
            
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
            
            % Verifying that the pump is connected. It will error out here
            % if the COM port is incorrect. Try five times before giving up
            % reset any previously written programs on the pump
            goodconct=false;
            cntr=1;
            while ~goodconct || cntr>5
                msg=obj.sendcmd('*RESET');
                if strcmp(msg,'00S')
                    goodconct=true;
                else
                    cntr=cntr+1;
                    pause(obj.serialWaitTime);
                end
            end
            if goodconct
                disp('Pump successfully connected!');
            else
                warning('Problem with pump connection')
            end
        end
        
        % delete pump object, closing serial
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
        
        % Method for communicating with the pump.
        function readString = sendcmd(obj,writeString,varargin)
            % Add the address, if necessary.
            if nargin > 2 && isnumeric(varargin{1}) && ...
                    isequal(size(varargin{1}),ones(1,2))
                % Set the number between 0 and 99 to a string with two
                % digits.
                numString = num2str(mod(round(varargin{1}),100),'%02d');
                
                % Concatenate address with write string.
                writeString = [numString writeString];
            end
            
            % Print the command.
            fprintf(obj.serialHandle,writeString);
            
            % Wait for bytes to appear at the port.
            pause(obj.serialWaitTime);
            
            % Read the bytes at the port.
            readString = fscanf(obj.serialHandle,'%s',...
                get(obj.serialHandle,'BytesAvailable'));
        end
    end
end