function Stop( self, channel )

self.AssertIsOpen
self.AssertIsReady

if nargin < 2
    self.StopAll
    return
end

msg = {'C0' , '00' , '03' , num2str(channel) , 'C1'};

if ~self.dummy
    
    [ FT_STATUS , numBytesWritten ] = self.FTDI_Handle.Write(  uint8(hex2dec(msg)) , uint32(length(msg)), uint32(0)); self.Update_FT_STATUS(FT_STATUS);
    
end

end % function
