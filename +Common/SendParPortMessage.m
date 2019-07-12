function SendParPortMessage( message )
global S

if strcmp( S.StimONOFF , 'ON' )
    
    % Send Trigger
    WriteParPort( S.ParPortMessages.(message) );
    WaitSecs    ( S.ParPortMessages.duration  );
    WriteParPort( 0                           );
    
end

end % function
