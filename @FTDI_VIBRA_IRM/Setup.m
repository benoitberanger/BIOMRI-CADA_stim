function Setup( self )

if ~self.dummy
    
    FT_STATUS = self.FTDI_Handle.ResetDevice();                                  self.Update_FT_STATUS(FT_STATUS);
    FT_STATUS = self.FTDI_Handle.Purge( uint32(1) );                             self.Update_FT_STATUS(FT_STATUS);
    FT_STATUS = self.FTDI_Handle.Purge( uint32(2) );                             self.Update_FT_STATUS(FT_STATUS);
    FT_STATUS = self.FTDI_Handle.SetBaudRate( uint32( 115200 ) );                self.Update_FT_STATUS(FT_STATUS);
    FT_STATUS = self.FTDI_Handle.SetRTS( true );                                 self.Update_FT_STATUS(FT_STATUS);
    FT_STATUS = self.FTDI_Handle.SetDTR( true );                                 self.Update_FT_STATUS(FT_STATUS);
    FT_STATUS = self.FTDI_Handle.SetFlowControl( uint16(0), uint8(0), uint8(0)); self.Update_FT_STATUS(FT_STATUS);
    FT_STATUS = self.FTDI_Handle.SetTimeouts( uint32(1), uint32(1));             self.Update_FT_STATUS(FT_STATUS);
    
end

self.IsReady = 1;

fprintf('[%s:%s] : done \n', class(self), mfilename)


end % function