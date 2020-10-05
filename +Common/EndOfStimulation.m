function TaskData = EndOfStimulation( TaskData, EP, ER, RR, KL, StartTime, StopTime )
global S

%% End of stimulation

% EventRecorder
ER.ClearEmptyEvents;
ER.ComputeDurations;
ER.BuildGraph;
ER.MakeBlocks;
ER.BuildGraph('block');
TaskData.ER = ER;

% Response Recorder
RR.ClearEmptyEvents;
RR.ComputeDurations;
% RR.MakeBlocks;
RR.BuildGraph;
TaskData.RR = RR;

% KbLogger
KL.GetQueue;
KL.Stop;
switch S.OperationMode
    case 'Acquisition'
    case 'FastDebug'
        if isempty(TaskData.Parameters.TR)
            TR = 0.300;
        else
            TR = TaskData.Parameters.TR;
        end
        nbVolumes = ceil( EP.Data{end,2} / TR ) ; % nb of volumes for the estimated time of stimulation
        KL.GenerateMRITrigger( TR , nbVolumes + 2 , StartTime );
    case 'RealisticDebug'
        if isempty(TaskData.Parameters.TR)
            TR = 0.300;
        else
            TR = TaskData.Parameters.TR;
        end
        nbVolumes = ceil( EP.Data{end,2} / TR ); % nb of volumes for the estimated time of stimulation
        KL.GenerateMRITrigger( TR , nbVolumes + 2, StartTime );
    otherwise
end
KL.ScaleTime(StartTime);
KL.ComputeDurations;
KL.BuildGraph;
TaskData.KL = KL;

% Save some values
TaskData.StartTime = StartTime;
TaskData.StopTime  = StopTime;


%% Send infos to base workspace

assignin('base','EP',EP)
assignin('base','ER',ER)
assignin('base','RR',RR)
assignin('base','KL',KL)

assignin('base','TaskData',TaskData)


%% Close parallel port

switch S.ParPort
    
    case 'On'
        CloseParPort;
        
    case 'Off'
        
end


%% Diagnotic

switch S.OperationMode
    
    case 'Acquisition'
        
    case 'FastDebug'
        plotDelay(EP,ER)
        
    case 'RealisticDebug'
        plotDelay(EP,ER)
        
end


end % function
