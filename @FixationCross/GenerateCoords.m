function GenerateCoords( self )

hRect = CenterRectOnPoint([0 0 self.dim   self.width],self.center(1),self.center(2));
vRect = CenterRectOnPoint([0 0 self.width self.dim  ],self.center(1),self.center(2));

self.allCoords = [hRect; vRect]';

end
