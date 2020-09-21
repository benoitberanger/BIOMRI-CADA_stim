function [ TaskData ] = Task( stim_duration )
global S

S.PTB.slack = 0.001;

try
    %% Tunning of the task
    
    [ EP, Parameters ] = CADA.Planning( stim_duration );
    TaskData.Parameters = Parameters;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    % This is a pointer copy, not a deep copy
    S.EP = EP;
    S.ER = ER;
    S.RR = KL;
    
    
    %% Prepare objects
    
    CROSS        = CADA.Prepare.Cross;
    CHECKERBOARD = CADA.Prepare.Checkerboard;
    AUDIOCLICK   = CADA.Prepare.AudioFile;
    
    
    %% Eyelink
    
    Common.StartRecordingEyelink;
    
    
    %% Go
    
    dt = 1 / S.Parameters.Checkerboard.Frequency;
    
    % Initialize some variables
    EXIT = 0;
    
    % Loop over the EventPlanning
    for evt = 1 : size( EP.Data , 1 )
        
        Common.CommandWindowDisplay( EP, evt );
        
        switch EP.Data{evt,1}
            
            case 'StartTime' % --------------------------------------------
                
                CROSS.Draw
                Screen('DrawingFinished', S.PTB.wPtr);
                Screen('Flip', S.PTB.wPtr);
                StartTime = Common.StartTimeEvent;
                
            case 'StopTime' % ---------------------------------------------
                
                [ ER, RR, StopTime ] = Common.StopTimeEvent( EP, ER, RR, StartTime, evt );
                
                
            case 'Rest' % -------------------------------------------------
                
                CROSS.Draw
                
                when = StartTime + EP.Data{evt,2} - S.PTB.slack;
                Screen('DrawingFinished', S.PTB.wPtr);
                lastFlipOnset = Screen('Flip', S.PTB.wPtr, when);
                Common.SendParPortMessage(EP.Data{evt,1});
                ER.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                RR.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] []                });
                
                when = StartTime + EP.Data{evt+1,2} - S.PTB.slack;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                secs = lastFlipOnset;
                while secs < when
                    
                    % Fetch keys
                    [keyIsDown, secs, keyCode] = KbCheck;
                    
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    
                end % while
                if EXIT
                    break
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
            case {'Stim'} % --------------------------------------
                
                when = StartTime + EP.Data{evt,2} - S.PTB.slack;
                Screen('DrawingFinished', S.PTB.wPtr);
                conditionFlipOnset = Screen('Flip', S.PTB.wPtr, when);
                
                CHECKERBOARD.DrawFlic
                Screen('DrawingFinished', S.PTB.wPtr);
                lastFlipOnset = Screen('Flip', S.PTB.wPtr);
                
                Common.SendParPortMessage(EP.Data{evt,1});
                ER.AddEvent({EP.Data{evt,1} conditionFlipOnset-StartTime [] EP.Data{evt,4:end}});
                RR.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime      [] []                });
                
                when = StartTime + EP.Data{evt+1,2} - S.PTB.slack - dt*2;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                secs = conditionFlipOnset;
                while secs < when
                    
                    CHECKERBOARD.DrawFlac
                    Screen('DrawingFinished', S.PTB.wPtr);
                    lastFlipOnset = Screen('Flip', S.PTB.wPtr, lastFlipOnset + dt);
                    
                    CHECKERBOARD.DrawFlic
                    Screen('DrawingFinished', S.PTB.wPtr);
                    lastFlipOnset = Screen('Flip', S.PTB.wPtr, lastFlipOnset + dt);
                    
                    % Fetch keys
                    [keyIsDown, secs, keyCode] = KbCheck;
                    
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    
                end % while
                if EXIT
                    break
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
            case 'AskClick'
                
                when = StartTime + EP.Data{evt,2} - S.PTB.slack;
                lastFlipOnset = AUDIOCLICK.Playback(when);
                Common.SendParPortMessage(EP.Data{evt,1});
                ER.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                RR.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] []                });
                
                when = StartTime + EP.Data{evt+1,2} - S.PTB.slack;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                secs = lastFlipOnset;
                while secs < when
                    
                    % Fetch keys
                    [keyIsDown, secs, keyCode] = KbCheck;
                    
                    if keyIsDown
                        % ~~~ ESCAPE key ? ~~~
                        [ EXIT, StopTime ] = Common.Interrupt( keyCode, ER, RR, StartTime );
                        if EXIT
                            break
                        end
                    end
                    
                end % while
                if EXIT
                    break
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
            otherwise % ---------------------------------------------------
                
                error('unknown envent')
                
        end % switch
        
        % This flag comes from Common.Interrupt, if ESCAPE is pressed
        if EXIT
            break
        end
        
    end % for
    
    
    %% End of stimulation
    
    % Close the audio device
    PsychPortAudio('Close');
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, StartTime, StopTime );
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
