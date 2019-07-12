function [ Parameters ] = GetParameters
% GETPARAMETERS Prepare common parameters
global S

if isempty(S)
    %     S.Environement = 'MRI';
    %     S.Side         = 'Left';
    %     S.Task         = 'MRI';
end


%% Echo in command window

EchoStart(mfilename)


%% Set parameters

%%%%%%%%%%%
%  Audio  %
%%%%%%%%%%%

% Parameters.Audio.SamplingRate            = 44100; % Hz

% Parameters.Audio.Playback_Mode           = 1; % 1 = playback, 2 = record
% Parameters.Audio.Playback_LowLatencyMode = 1; % {0,1,2,3,4}
% Parameters.Audio.Playback_freq           = Parameters.Audio.SamplingRate ;
% Parameters.Audio.Playback_Channels       = 2; % 1 = mono, 2 = stereo

% Parameters.Audio.Record_Mode             = 2; % 1 = playback, 2 = record
% Parameters.Audio.Record_LowLatencyMode   = 0; % {0,1,2,3,4}
% Parameters.Audio.Record_freq             = Parameters.Audio.SamplingRate;
% Parameters.Audio.Record_Channels         = 1; % 1 = mono, 2 = stereo


%%%%%%%%%%%%%%
%   Screen   %
%%%%%%%%%%%%%%

Parameters.Video.ScreenBackgroundColor = [128 128 128]; % [R G B] ( from 0 to 255 )

%%%%%%%%%%%%
%   Text   %
%%%%%%%%%%%%
Parameters.Text.SizeRatio   = 0.07; % Size = ScreenWide *ratio
Parameters.Text.Font        = 'Arial';
Parameters.Text.Color       = [255 255 255]; % [R G B] ( from 0 to 255 )
Parameters.Text.ClickCorlor = [0   255 0  ]; % [R G B] ( from 0 to 255 )

%%%%%%%%%%%%%%%
%   BIOMRI_CADA   %
%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%
%  Keybinds  %
%%%%%%%%%%%%%%

KbName('UnifyKeyNames');

Parameters.Keybinds.TTL_t_ASCII          = KbName('t'); % MRI trigger has to be the first defined key
% Parameters.Keybinds.emulTTL_s_ASCII      = KbName('s');
Parameters.Keybinds.Stop_Escape_ASCII    = KbName('ESCAPE');


%% Echo in command window

EchoStop(mfilename)


end