classdef Checkerboard < baseObject
    %CHECKERBOARD Class to prepare and draw a fixation cross in PTB
    
    %% Properties
    
    properties
        
        % Parameters
        
        ScreenWidth  = zeros(0) % px
        ScreenHeight = zeros(0) % px
        
        nSquareWidth = zeros(0)
        
        FlicColor    = zeros(0,4) % [R G B a] from 0 to 255
        FlacColor    = zeros(0,4) % [R G B a] from 0 to 255
        
        
        % Internal variables
        
        FlicRect     = zeros(0,4)
        FlacRect     = zeros(0,4)
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = Checkerboard( ScreenWidth , ScreenHeight ,  nSquareWidth , FlicColor, FlacColor )
                        
            % Arguments ?
            if nargin > 0
                
                self.ScreenWidth  = ScreenWidth;
                self.ScreenHeight = ScreenHeight;
                
                self.nSquareWidth = nSquareWidth;
                
                self.FlicColor    = FlicColor;
                self.FlacColor    = FlacColor;
        
                
                % ================== Callback =============================
                
                self.GenRect
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
