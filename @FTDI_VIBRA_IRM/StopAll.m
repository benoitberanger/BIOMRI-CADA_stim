function StopAll( self )

self.AssertIsOpen
self.AssertIsReady

self.Stop(1)
self.Stop(2)
self.Stop(3)
self.Stop(4)

end % function
