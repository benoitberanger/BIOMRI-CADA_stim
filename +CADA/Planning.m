function [ EP , Parameters ] = Planning( stim_duration, TR )
global S

if nargout < 1 % only to plot the paradigme when we execute the function outside of the main script
    S.OperationMode = 'Acquisition';
    stim_duration   = 2;   % second
    TR              = 250; % millisecond, or []
end

TR = TR / 1000; % ms -> s
Parameters.TR = TR;


%% Paradigme

switch stim_duration
    case 1
        Parameters.StimDuration =  1; % second
        Parameters.RestDuration = 30; % second
    case 2
        Parameters.StimDuration =  2; % second
        Parameters.RestDuration = 25; % second
    case 3
        Parameters.StimDuration =  3; % second
        Parameters.RestDuration = 30; % second
    case 5
        Parameters.StimDuration =  5; % second
        Parameters.RestDuration = 30; % second
    case 10
        Parameters.StimDuration = 10; % second
        Parameters.RestDuration = 30; % second
    otherwise
        error('wrong stim_duration')
end


switch S.OperationMode
    case 'Acquisition'
        Parameters.ToTalTime          = 300 ; % second
        Parameters.ClickAudioDuration = 1.4;  % second => this is the lenght  of the .wav file
    case 'FastDebug'
        Parameters.ToTalTime          = 30 ;  % second
        Parameters.StimDuration       = 1;    % second
        Parameters.RestDuration       = 5;    % second
        Parameters.ClickAudioDuration = 0.5;  % second
    case 'RealisticDebug'
        Parameters.ToTalTime          = 30 ;  % second
        Parameters.StimDuration       = 2;    % second
        Parameters.RestDuration       = 5;    % second
        Parameters.ClickAudioDuration = 0.5;  % second
end

if isempty(TR)
    
    % TimeVectRest =                       0 : Parameters.StimDuration + Parameters.RestDuration : Parameters.ToTalTime - Parameters.RestDuration;
    TimeVectStim = Parameters.RestDuration : Parameters.StimDuration + Parameters.RestDuration : Parameters.ToTalTime - Parameters.RestDuration - Parameters.StimDuration;
    nStim = length(TimeVectStim);
    
    Jitter   = Shuffle(                         0.5 + (1 : nStim) / nStim                             ); % Jitter = [0.5 ...  1.5];
    AskClick = Shuffle( Parameters.RestDuration/4   + (1 : nStim) / nStim * Parameters.RestDuration/2 ); % Jitter = [5   ... 10  ];
    
else
    
    div = Parameters.StimDuration / TR;
    up  = ceil(div);
    rem = up-div;
    dtR = rem * TR;
    dtL = TR - dtR;
    
    if mod(Parameters.StimDuration+Parameters.RestDuration,TR) ~= 0
        SyncRestDuration = Parameters.RestDuration - dtL;
    else
        SyncRestDuration = Parameters.RestDuration;
    end
    Parameters.SyncRestDuration = SyncRestDuration;
    
    TimeVectStim = SyncRestDuration : Parameters.StimDuration + SyncRestDuration : Parameters.ToTalTime - SyncRestDuration - Parameters.StimDuration;
    nStim = length(TimeVectStim);
    AskClick = Shuffle( SyncRestDuration/4   + (1 : nStim) / nStim * SyncRestDuration/2 ); % Jitter = [5   ... 10  ];
    
end

fprintf('nStim = %d \n', nStim)


%% Define a planning <--- paradigme


% Create and prepare
header = { 'event_name', 'onset(s)', 'duration(s)' };
EP     = EventPlanning(header);

% NextOnset = PreviousOnset + PreviousDuration
NextOnset = @(EP) EP.Data{end,2} + EP.Data{end,3};


% --- Start ---------------------------------------------------------------

EP.AddStartTime('StartTime',0);

% --- Stim ----------------------------------------------------------------

if isempty(TR)
    
    EP.AddPlanning({ 'Rest' NextOnset(EP) Parameters.RestDuration })
    
    for evt = 1 : nStim
        
        EP.AddPlanning({ 'Stim'     NextOnset(EP) Parameters.StimDuration                                                               })
        EP.AddPlanning({ 'Rest'     NextOnset(EP) AskClick(evt)                                                                         })
        EP.AddPlanning({ 'AskClick' NextOnset(EP) Parameters.ClickAudioDuration                                                         })
        EP.AddPlanning({ 'Rest'     NextOnset(EP) Parameters.RestDuration - AskClick(evt) - Parameters.ClickAudioDuration + Jitter(evt) })
        
    end
    
else
    
    EP.AddPlanning({ 'Rest' NextOnset(EP) round(Parameters.RestDuration/TR) * TR }) % first rest block has to be a N x TR
    
    for evt = 1 : nStim
        
        EP.AddPlanning({ 'Stim'     NextOnset(EP) Parameters.StimDuration                                                               })
        EP.AddPlanning({ 'Rest'     NextOnset(EP) AskClick(evt)                                                                         })
        EP.AddPlanning({ 'AskClick' NextOnset(EP) Parameters.ClickAudioDuration                                                         })
        EP.AddPlanning({ 'Rest'     NextOnset(EP) SyncRestDuration - AskClick(evt) - Parameters.ClickAudioDuration                      })
        
    end
    
    Stim_idx   = strcmp( EP.Data(:,1), 'Stim' );
    Stim_onset = cell2mat(  EP.Data(Stim_idx,2) );
    REM        = mod(Stim_onset,TR);
    REM( REM < 0.001 ) = 0; % I don't know why, but the Shuffle (higher in the code) can non-zero values, such as 5.1292e-14.
    IsInSync   =  REM == 0;
    if ~all(IsInSync)
        error('not in sync with TR')
        % warning('not in sync with TR')
        % keyboard
    end
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