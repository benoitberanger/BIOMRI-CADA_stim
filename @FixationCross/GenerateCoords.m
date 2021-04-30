function GenerateCoords( self )

hRect = CenterRectOnPoint([0 0 self.currentDim   self.currentWidth],self.center(1),self.center(2));
vRect = CenterRectOnPoint([0 0 self.currentWidth self.currentDim  ],self.center(1),self.center(2));

self.allCoords = [hRect; vRect]';

end
