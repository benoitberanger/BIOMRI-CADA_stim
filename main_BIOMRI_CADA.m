function main_BIOMRI_CADA(hObject, ~)
% BIOMRI_CADA_main is the main program, calling the different tasks and
% routines, accoding to the paramterts defined in the GUI

%% GUI : open a new one or retrive data from the current one

if nargin == 0
    
    gui_BIOMRI_CADA;
    
    return
    
end

handles = guidata(hObject); % retrieve GUI data


%% MAIN : Clean the environment

clc
sca
rng('default')
rng('shuffle')


%% MAIN : Initialize the main structure

global S
S               = struct; % S is the main structure, containing everything usefull, and used everywhere
S.TimeStamp     = datestr(now, 'yyyy-mm-dd HH:MM'); % readable
S.TimeStampFile = datestr(now, 30                ); % to sort automatically by time of creation


%% GUI : Task selection

switch get(hObject,'Tag')
    
    case 'pushbutton_CADA_inSync_2'
        Task = 'CADA_inSync_2';
        
    case 'pushbutton_CADA_inSync_10'
        Task = 'CADA_inSync_10';

        
    case 'pushbutton_EyelinkCalibration'
        Task = 'EyelinkCalibration';
        
    otherwise
        error('BIOMRI_CADA:TaskSelection','Error in Task selection')
end

S.Task = Task;


%% GUI : Save mode selection

switch get(get(handles.uipanel_SaveMode,'SelectedObject'),'Tag')
    case 'radiobutton_SaveData'
        SaveMode = 'SaveData';
    case 'radiobutton_NoSave'
        SaveMode = 'NoSave';
    otherwise
        warning('BIOMRI_CADA:SaveSelection','Error in SaveMode selection')
end

S.SaveMode = SaveMode;


%% GUI : Mode selection

switch get(get(handles.uipanel_OperationMode,'SelectedObject'),'Tag')
    case 'radiobutton_Acquisition'
        OperationMode = 'Acquisition';
    case 'radiobutton_FastDebug'
        OperationMode = 'FastDebug';
    case 'radiobutton_RealisticDebug'
        OperationMode = 'RealisticDebug';
    otherwise
        warning('BIOMRI_CADA:ModeSelection','Error in Mode selection')
end

S.OperationMode = OperationMode;


%% GUI + MAIN : Subject ID & Run number

SubjectID = get(handles.edit_SubjectID,'String');

if isempty(SubjectID)
    error('BIOMRI_CADA:SubjectIDLength','\n SubjectID is required \n')
end

% Prepare path
DataPath = [fileparts(pwd) filesep 'data' filesep SubjectID filesep];

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if ~exist(DataPath, 'dir')
        mkdir(DataPath);
    end
    
end

% DataFile_noRun = sprintf('%s%s_%s_%s_%s', DataPath, S.TimeStampFile, SubjectID, Environement, Task );
DataFile_noRun = sprintf('%s_%s', SubjectID, Task );

% Auto-incrementation of run number
% -------------------------------------------------------------------------
% Fetch content of the directory
dirContent = dir(DataPath);

% Is there file of the previous run ?
previousRun = nan(length(dirContent)-2,1);
for f = 3 : length(dirContent) % avoid . and ..
    runNumber = regexp(dirContent(f).name,[DataFile_noRun '_run?(\d+)'],'tokens');
    if ~isempty(runNumber) % yes there is a file
        runNumber = runNumber{1}{:};
        previousRun(f) = str2double(runNumber); % save the previous run numbers
    else % no file found
        previousRun(f) = 0; % affect zero
    end
end

LastRunNumber = max(previousRun);
% If no previous run, LastRunNumber is 0
if isempty(LastRunNumber)
    LastRunNumber = 0;
end

RunNumber = LastRunNumber + 1;
% -------------------------------------------------------------------------

DataFile     = sprintf('%s%s_%s_%s_run%0.2d', DataPath, S.TimeStampFile, SubjectID, Task, RunNumber );
DataFileName = sprintf(  '%s_%s_%s_run%0.2d',           S.TimeStampFile, SubjectID, Task, RunNumber );

S.SubjectID     = SubjectID;
S.RunNumber     = RunNumber;
S.DataPath      = DataPath;
S.DataFile      = DataFile;
S.DataFileName  = DataFileName;


%% MAIN : Controls for SubjectID depending on the Mode selected

switch OperationMode
    
    case 'Acquisition'
        
        % Empty subject ID
        if isempty(SubjectID)
            error('BIOMRI_CADA:MissingSubjectID','\n For acquisition, SubjectID is required \n')
        end
        
        % Acquisition => save data
        if ~get(handles.radiobutton_SaveData,'Value')
            warning('BIOMRI_CADA:DataShouldBeSaved','\n\n\n In acquisition mode, data should be saved \n\n\n')
        end
        
end


%% GUI : Parallel port ?

switch get( handles.checkbox_ParPort , 'Value' )
    case 1
        ParPort = 'On';
    case 0
        ParPort = 'Off';
end
S.ParPort = ParPort;
S.ParPortMessages = Common.PrepareParPort;
handles.ParPort    = ParPort;


%% GUI : Check if Eyelink toolbox is available

switch get(get(handles.uipanel_EyelinkMode,'SelectedObject'),'Tag')
    
    case 'radiobutton_EyelinkOff'
        
        EyelinkMode = 'Off';
        
    case 'radiobutton_EyelinkOn'
        
        EyelinkMode = 'On';
        
        % 'Eyelink.m' exists ?
        status = which('Eyelink.m');
        if isempty(status)
            error('BIOMRI_CADA:EyelinkToolbox','no ''Eyelink.m'' detected in the path')
        end
        
        % Save mode ?
        if strcmp(S.SaveMode,'NoSave')
            error('BIOMRI_CADA:SaveModeForEyelink',' \n ---> Save mode should be turned on when using Eyelink <--- \n ')
        end
        
        % Eyelink connected ?
        Eyelink.IsConnected
        
        eyelink_max_finename = 8;
        str = ['a':'z' 'A':'Z' '0':'9'];
        ln_str = length(str);
        
        name_num = randi(ln_str,[1 eyelink_max_finename]);
        name_str = str(name_num);
        
        S.EyelinkFile = name_str;
        
    otherwise
        
        warning('BIOMRI_CADA:EyelinkMode','Error in Eyelink mode')
        
end

S.EyelinkMode = EyelinkMode;


%% MAIN : Security : NEVER overwrite a file
% If erasing a file is needed, we need to do it manually

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if exist([DataFile '.mat'], 'file')
        error('MATLAB:FileAlreadyExists',' \n ---> \n The file %s.mat already exists .  <--- \n \n',DataFile);
    end
    
end


%% MAIN : Get stimulation parameters

S.Parameters = GetParameters;

% Screen mode selection
AvalableDisplays = get(handles.listbox_Screens,'String');
SelectedDisplay  = get(handles.listbox_Screens,'Value' );
S.ScreenID       = str2double( AvalableDisplays(SelectedDisplay) );


%% GUI : Windowed screen ?

switch get(handles.checkbox_WindowedScreen,'Value')
    
    case 1
        WindowedMode = 'On';
    case 0
        WindowedMode = 'Off';
    otherwise
        warning('BIOMRI_CADA:WindowedScreen','Error in WindowedScreen')
        
end

S.WindowedMode = WindowedMode;


%% MAIN : Open PTB window & sound

S.PTB = StartPTB;


%% MAIN : Task run

EchoStart(Task)

TR = str2double( get(handles.edit_TR,'String') );
S.TR = TR;

switch Task
    
    case 'CADA_inSync_2'
        TaskData = CADA.Task(2,TR);
        
    case 'CADA_inSync_10'
        TaskData = CADA.Task(10,TR);
        
        
        
    case 'EyelinkCalibration'
        Eyelink.Calibration(S.PTB.wPtr);
        TaskData.ER.Data = {};
        
    otherwise
        error('BIOMRI_CADA:Task','Task ?')
end

EchoStop(Task)

S.TaskData = TaskData;


%% MAIN : Save files on the fly : just a security in case of crash of the end the script

save([fileparts(pwd) filesep 'data' filesep 'LastS'],'S');


%% MAIN : Close PTB

sca;
Priority( 0 );


%% MAIN : SPM data organization

[ names , onsets , durations ] = SPMnod;


%% MAIN : Saving data strucure

if strcmp(SaveMode,'SaveData') && strcmp(OperationMode,'Acquisition')
    
    if ~exist(DataPath, 'dir')
        mkdir(DataPath);
    end
    
    save(DataFile,     'S', 'names', 'onsets', 'durations');
    save([DataFile '_SPM'], 'names', 'onsets', 'durations');
    
end


%% MAIN : Send S and SPM nod to workspace

assignin('base', 'S'        , S        );
assignin('base', 'names'    , names    );
assignin('base', 'onsets'   , onsets   );
assignin('base', 'durations', durations);


%% MAIN : End recording of Eyelink

% Eyelink mode 'On' ?
if strcmp(S.EyelinkMode,'On')
    
    % Stop recording and retrieve the file
    Eyelink.StopRecording( S.EyelinkFile )
    
end


%% MAIN + GUI : Ready for another run

set(handles.text_LastFileNameAnnouncer, 'Visible','on'                             )
set(handles.text_LastFileName         , 'Visible','on'                             )
set(handles.text_LastFileName         , 'String' , DataFile(length(DataPath)+1:end))

WaitSecs(0.100);
pause(0.100);
fprintf('\n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')
fprintf('  Ready for another session   \n')
fprintf('~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n')


end % function
