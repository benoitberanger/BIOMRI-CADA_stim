function ParPortMessages = PrepareParPort
global S

%% On ? Off ?

switch S.ParPort
    
    case 'On'
        
        % Open parallel port
        OpenParPort;
        
        % Set pp to 0
        WriteParPort(0)
        
    case 'Off'
        
end

%% Prepare messages

% fill here...
msg.Rest     = 1;
msg.Stim     = 2;
msg.AskClick = 3;


%% Finalize

% Pulse duration
msg.duration    = 0.003; % seconds

ParPortMessages = msg; % shortcut

end % function
