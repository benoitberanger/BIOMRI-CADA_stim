classdef FixationCross < baseObject
    %FIXATIONCROSS Class to prepare and draw a fixation cross in PTB
    
    %% Properties
    
    properties
        
        % Parameters
        
        baseDim      = zeros(0)   % size of cross arms, in pixels
        baseWidth    = zeros(0)   % width of each arms, in pixels
        baseColor    = zeros(0,4) % [R G B a] from 0 to 255
        center       = zeros(0,2) % [ CenterX CenterY ] of the cross, in pixels
        
        % Internal variables
        currentDim   = zeros(0)   % size of cross arms, in pixels
        currentWidth = zeros(0)   % width of each arms, in pixels
        currentColor = zeros(0,4) % [R G B a] from 0 to 255
        allCoords    = zeros(2,4) % coordinates of the cross for PTB, in pixels
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        function self = FixationCross( dim , width ,  color , center )
            % obj = FixationCross( dim=ScreenHeight/10 (pixels) , width=5 (pixels) ,  color=[128 128 128 255] from 0 to 255 , center = [ CenterX CenterY ] (pixels) )
            
            % ================ Check input argument =======================
            
            % Arguments ?
            if nargin > 0
                
                % --- dim ----
                assert( isscalar(dim) && isnumeric(dim) && dim>0 && dim==round(dim) , ...
                    'dim = size of cross arms, in pixels' )
                
                % --- width ----
                assert( isscalar(width) && isnumeric(width) && width>0 && width==round(width) , ...
                    'width = width of each arms, in pixels' )
                
                % --- color ----
                assert( isvector(color) && isnumeric(color) && all( uint8(color)==color ) , ...
                    'color = [R G B a] from 0 to 255' )
                
                % --- center ----
                assert( isvector(center) && isnumeric(center) && all( center>0 ) && all(center == round(center)) , ...
                    'center = [ CenterX CenterY ] of the cross, in pixels' )
                
                self.baseDim      = dim;
                self.currentDim   = dim;
                self.baseWidth    = width;
                self.currentWidth = width;
                self.baseColor    = color;
                self.currentColor = color;
                self.center       = center;
                
                % ================== Callback =============================
                
                self.GenerateCoords
                
            else
                % Create empty instance
            end
            
        end
        
        
    end % methods
    
    
end % class
