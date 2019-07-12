function Open( self )

if ~self.dummy
    
    if ~self.IsOpen
        
        self.FTDI_Handle = FTD2XX_NET.FTDI;
        FT_STATUS        = self.FTDI_Handle.OpenByIndex( uint32( 0 ) ); self.Update_FT_STATUS(FT_STATUS);
        self.IsOpen      = 1;
        fprintf('[%s:%s] : done \n'          , class(self), mfilename)
        
    else
        fprintf('[%s:%s] : Already opened \n', class(self), mfilename)
    end
    
else
    
    self.IsOpen      = 1;
    fprintf('[%s:%s] : done \n'          , class(self), mfilename)
    
end

end % function
