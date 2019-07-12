classdef FTDI_VIBRA_IRM < handle
    %FTDI_VIBRA_IRM to command Technoconcept VIBRA IRM
    
    
    %% Properties
    
    properties
        
        FTD2XX_NET_dll_path = 'C:\FTD2XX_NET.dll'
        FTDI_Handle
        FT_STATUS
        IsOpen              = 0
        IsReady             = 0
        Value               = [100 100 100 100]; % [0-100] : percentage(%) of valve opened
        
        dummy               = 0 % for non supported sytems
        
    end % properties
    
    
    %% Methods
    
    methods
        
        % -----------------------------------------------------------------
        %                           Constructor
        % -----------------------------------------------------------------
        
        function self = FTDI_VIBRA_IRM( DLL_path )
            
            if ispc
                
                if nargin
                    assert( exist( DLL_path , 'file') == 2 , 'Not a valide file : %s', DLL_path)
                    self.FTD2XX_NET_dll_path = DLL_path;
                end
                
                % Place dll in directory of your choice.
                NET.addAssembly(self.FTD2XX_NET_dll_path);
                
            elseif isunix
                
                self.dummy = 1;
                warning('FTDI_VIBRA_IRM is in dummy mode')
                
            end
            
        end % function : ctor
        
    end % methods
    
    methods(Static)
        
        out = GUI_VIBRA_IRM( container )
        
    end % methods static
    
    
end % classdef
