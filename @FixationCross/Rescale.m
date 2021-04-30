function Rescale( self, factor )

self.currentDim   = self.baseDim   * factor;
self.currentWidth = self.baseWidth * factor;

if mod(self.currentDim,2) ~= 0
    self.currentDim = self.currentDim + 1 ;
end

if mod(self.currentWidth,2) ~= 0
    self.currentWidth = self.currentWidth + 1 ;
end

self.GenerateCoords();

end % function
