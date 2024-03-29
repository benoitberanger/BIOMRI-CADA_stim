function [ PTB ] = StartPTB
% STARTPTB starts audio and video systems of PTB
global S

%% Echo in command window

EchoStart(mfilename)


%% Video

% Shortcut
Video = S.Parameters.Video;

% Use GStreamer : for videos
% Screen('Preference', 'OverrideMultimediaEngine', 1);

% PTB opening screen will be empty = black screen
Screen('Preference', 'VisualDebugLevel', 1);

% Open PTB display window
switch S.WindowedMode
    case 'Off'
        if IsLinux && length(Screen('Screens')) == 1
            WindowRect = [0 0 1024 768];
        else
            WindowRect = [];
        end
    case 'On'
        factor = 0.5;
        [ScreenWidth, ScreenHeight]=Screen('WindowSize', S.ScreenID);
        if IsLinux && length(Screen('Screens')) == 1
            WindowRect = [0 0 1024 768];
        else
            WindowRect = ScaleRect( [0 0 ScreenWidth ScreenHeight] , factor , factor );
        end
    otherwise
end

color_depth = []; % bit, only assigna specific value for backward compatibility
multisample = 4; % samples for anti-aliasing

try
    [PTB.wPtr,PTB.wRect] = Screen('OpenWindow',S.ScreenID,Video.ScreenBackgroundColor,WindowRect,color_depth,[],[],multisample);
catch err
    disp(err)
    Screen('Preference', 'SkipSyncTests', 1)
    [PTB.wPtr,PTB.wRect] = Screen('OpenWindow',S.ScreenID,Video.ScreenBackgroundColor,WindowRect,color_depth,[],[],multisample);
end

% Set max priority
PTB.oldLevel         = Priority();
PTB.maxPriorityLevel = MaxPriority( PTB.wPtr );
PTB.newLevel         = Priority( PTB.maxPriorityLevel );

% Refresh time of the monitor
PTB.slack = Screen('GetFlipInterval', PTB.wPtr)/2;
PTB.IFI   = Screen('GetFlipInterval', PTB.wPtr);
PTB.FPS   = Screen('FrameRate', PTB.wPtr);

% Set up alpha-blending for smooth (anti-aliased) lines and alpha-blending
% (transparent background textures)
Screen('BlendFunction', PTB.wPtr, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Center
[ PTB.CenterH , PTB.CenterV ] = RectCenter( PTB.wRect );

% B&W colors
PTB.Black = BlackIndex( PTB.wPtr );
PTB.White = WhiteIndex( PTB.wPtr );

% Text
Screen('TextSize' , PTB.wPtr, round(S.Parameters.Text.SizeRatio * PTB.wRect(4)));
Screen('TextFont' , PTB.wPtr, S.Parameters.Text.Font);
Screen('TextColor', PTB.wPtr, S.Parameters.Text.Color);
Screen('Preference', 'TextRenderer', 1);


%% Priority

% Set max priority
PTB.oldLevel         = Priority();
PTB.maxPriorityLevel = MaxPriority( [] );
PTB.newLevel         = Priority( PTB.maxPriorityLevel );


%% Warm up

Screen('Flip',PTB.wPtr);
WaitSecs(0.100);
GetSecs;
KbCheck;


%% Echo in command window

EchoStop(mfilename)


end
