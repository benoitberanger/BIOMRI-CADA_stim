function [ EP , Parameters ] = Planning
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.OperationMode = 'Acquisition';
end

TR = 2.76; % seconds


%% Paradigme

switch S.OperationMode
    case 'Acquisition'
        Parameters.InitRestDuration    = 60;         % second
        Parameters.RestDuration        = [40 40+TR]; % second
        Parameters.StimDuration        = 40;         % second
        Parameters.NrRepetitions       = 3;
    case 'FastDebug'
        Parameters.InitRestDuration    = 1;          % second
        Parameters.RestDuration        = [2 2.5];    % second
        Parameters.StimDuration        = 5;          % second
        Parameters.NrRepetitions       = 2;
    case 'RealisticDebug'
        Parameters.InitRestDuration    = 1;          % second
        Parameters.RestDuration        = [2 2.5];    % second
        Parameters.StimDuration        = 5;          % second
        Parameters.NrRepetitions       = 2;
end

jitter = Shuffle(TR/Parameters.NrRepetitions * rand(1,3) + linspace(0,TR - TR/Parameters.NrRepetitions,3));


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name', 'onset(s)', 'duration(s)' };
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddStartTime('StartTime',0);

% --- Stim ----------------------------------------------------------------

EP.AddPlanning({ 'Rest' NextOnset(EP) Parameters.InitRestDuration })


for evt = 1 : Parameters.NrRepetitions
    
    EP.AddPlanning({ 'Stim' NextOnset(EP) Parameters.StimDuration                  })
    EP.AddPlanning({ 'Rest' NextOnset(EP) Parameters.RestDuration(1) + jitter(evt) })
    
end

% --- Stop ----------------------------------------------------------------

EP.AddStopTime('StopTime',NextOnset(EP));


%% Display

% To prepare the planning and visualize it, we can execute the function
% without output argument

if nargout < 1
    
    fprintf( '\n' )
    fprintf(' \n Total stim duration : %g seconds \n' , NextOnset(EP) )
    fprintf( '\n' )
    
    EP.Plot
    
end


end % function