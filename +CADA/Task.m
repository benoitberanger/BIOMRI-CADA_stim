function [ TaskData ] = Task( stim_duration, TR )
global S

S.PTB.slack = 0.001;

try
    %% Tunning of the task
    
    [ EP, Parameters ] = CADA.Planning( stim_duration, TR );
    TaskData.Parameters = Parameters;
    
    % End of preparations
    EP.BuildGraph;
    TaskData.EP = EP;
    
    
    %% Prepare event record and keybinf logger
    
    [ ER, RR, KL ] = Common.PrepareRecorders( EP );
    
    % This is a pointer copy, not a deep copy
    S.EP = EP;
    S.ER = ER;
    S.RR = RR;
    S.KL = KL;
    
    
    %% Prepare objects
    
    CROSS        = CADA.Prepare.Cross;
    CHECKERBOARD = CADA.Prepare.Checkerboard;
    
    
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
                        if keyCode(S.Parameters.Fingers.Right)
                            fprintf('>>> click <<< \n')
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
                        if keyCode(S.Parameters.Fingers.Right)
                            fprintf('>>> click <<< \n')
                        end
                    end
                    
                end % while
                if EXIT
                    break
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                
            case 'Control'
                
                factor = 1.3;
                
                transit_duration = EP.Data{evt,3};
                half_transit_duration = transit_duration/2;
                nFrames         = round(transit_duration/S.PTB.IFI);
                nFrames_plateau = round(half_transit_duration/S.PTB.IFI);
                nFrames_rise    = round(half_transit_duration/2/S.PTB.IFI);
                
                color_steps  = linspace(128,0,nFrames_rise);
                factor_steps = linspace(1,factor,nFrames_rise);
                
                when = StartTime + EP.Data{evt,2} - S.PTB.slack;
                CROSS.Draw();
                lastFlipOnset = Screen('Flip', S.PTB.wPtr, when);
                Common.SendParPortMessage(EP.Data{evt,1});
                ER.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] EP.Data{evt,4:end}});
                RR.AddEvent({EP.Data{evt,1} lastFlipOnset-StartTime [] []                });
                
                for i = 1 : nFrames_rise
                    if keyCode(S.Parameters.Fingers.Right)
                        fprintf('>>> click <<< \n')
                    end
                    CROSS.currentColor = [128 color_steps(i) color_steps(i)];
                    CROSS.Rescale(factor_steps(i));
                    CROSS.Draw();
                    Screen('Flip',S.PTB.wPtr);
                end
                for i = 1 : nFrames_plateau
                    if keyCode(S.Parameters.Fingers.Right)
                        fprintf('>>> click <<< \n')
                    end
                    CROSS.Draw();
                    Screen('Flip',S.PTB.wPtr);
                end
                color_steps  = fliplr( color_steps);
                factor_steps = fliplr(factor_steps);
                for i = 1 : nFrames_rise
                    if keyCode(S.Parameters.Fingers.Right)
                        fprintf('>>> click <<< \n')
                    end
                    CROSS.currentColor = [128 color_steps(i) color_steps(i)];
                    CROSS.Rescale(factor_steps(i));
                    CROSS.Draw();
                    Screen('Flip',S.PTB.wPtr);
                end
                
                
            otherwise % ---------------------------------------------------
                
                error('unknown envent')
                
        end % switch
        
        % This flag comes from Common.Interrupt, if ESCAPE is pressed
        if EXIT
            break
        end
        
    end % for
    
    
    %% End of stimulation
    
    TaskData = Common.EndOfStimulation( TaskData, EP, ER, RR, KL, StartTime, StopTime );
    
    
catch err
    
    Common.Catch( err );
    
end

end % function
