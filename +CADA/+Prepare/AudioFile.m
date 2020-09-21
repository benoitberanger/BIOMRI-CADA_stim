function [ AUDOICLICK ] = AudioFile
global S

AUDOICLICK = Wav( fullfile(pwd,'wav','appuyez-sur-le-bouton.wav') );

AUDOICLICK.Resample(S.Parameters.Audio.SamplingRate)
AUDOICLICK.LinkToPAhandle( S.PTB.Playback_pahandle );
AUDOICLICK.AssertReadyForPlayback; % just to check

end % function
