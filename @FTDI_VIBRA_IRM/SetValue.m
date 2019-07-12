function SetValue ( self , newValue )

assert( nargin == 2 , 'newValue is requred : [0-100] // [ [0-100] [0-100] [0-100] [0-100] ]')
assert( isnumeric(newValue) && isvector(newValue) && ( numel(newValue)==1 || numel(newValue)==4 ) , 'newValue is a vector with 1 or 4 elements' )
assert( all(newValue>=0) && all(newValue<=100) , 'all elements mus be in rage 1-100')

if numel(newValue)==1
    self.Value = repmat(newValue, [1 4]);
else
    self.Value = newValue;
end

end % function
