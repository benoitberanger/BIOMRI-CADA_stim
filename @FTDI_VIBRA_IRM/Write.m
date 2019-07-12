function Write( self, msg )

if ~self.dummy
    
    [ FT_STATUS , numBytesWritten ] = self.FTDI_Handle.Write(  uint8(hex2dec(msg)) , uint32(length(msg)), uint32(0)); self.Update_FT_STATUS(FT_STATUS);
    
end

end % function
