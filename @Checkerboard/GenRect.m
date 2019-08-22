function GenRect( self )

ScreenWidth  = self.ScreenWidth;
ScreenHeight = self.ScreenHeight;

nSquareWidth = self.nSquareWidth;


%% Check input arguments

% --- Screen_Wide ---
if isscalar(ScreenWidth) && ScreenWidth > 0 && ScreenWidth == round(ScreenWidth)
else
    error('ScreenWide must be a positive integer')
end

% --- Screen_Height ---
if isscalar(ScreenHeight) && ScreenHeight > 0 && ScreenHeight == round(ScreenHeight)
else
    error('ScreenHeight must be a positive integer')
end

% --- Horizontal_number_of_squares ---
if isscalar(nSquareWidth) && nSquareWidth > 0 && nSquareWidth == round(nSquareWidth)
else
    error('Horizontal_number_of_squares must be a positive integer')
end


%% Squares postion computation

% Number of pixel of the squares wide
SquareSize  = ScreenWidth /nSquareWidth;

X = 0 : SquareSize : ScreenWidth ;
Y = 0 : SquareSize : ScreenHeight;

if mod(length(X),2)
    X(end+1) = X(end) + SquareSize;
end
if mod(length(Y),2)
    Y(end+1) = Y(end) + SquareSize;
end

% Creation of a grid : position of each square on the screen
[ X_Grid , Y_Grid ] = meshgrid( X , Y );

% Checkerboard matrix composed only whith 0 and 1. We will use this
% 'logical' checkboard as : 1 => white squares , 0 => black squares
CB = logical(repmat(eye(2),length(Y)/2,length(X)/2));
CB_reshaped = reshape(CB',1,[]);

% Transformation of the matrix into a vector (to fitt with the graphic
% functions syntax)
Squares_Xpos_reshaped = reshape(X_Grid',1,[]);
Squares_Ypos_reshaped = reshape(Y_Grid',1,[]);

% 1 => white squares
Squares_Xpos1 = Squares_Xpos_reshaped(CB_reshaped);
Squares_Ypos1 = Squares_Ypos_reshaped(CB_reshaped);

% 0 => black squares
Squares_Xpos2 = Squares_Xpos_reshaped(~CB_reshaped);
Squares_Ypos2 = Squares_Ypos_reshaped(~CB_reshaped);

% Sqares position such as : [ X1 Y1 X2 Y2 ;
%                             X1 Y1 X2 Y2 ;
%                             ...         ]
Checkerboard_1 = [Squares_Xpos1; Squares_Ypos1; Squares_Xpos1 + SquareSize; Squares_Ypos1 + SquareSize];
Checkerboard_2 = [Squares_Xpos2; Squares_Ypos2; Squares_Xpos2 + SquareSize; Squares_Ypos2 + SquareSize];


%% Saving data

self.FlicRect = Checkerboard_1;
self.FlacRect = Checkerboard_2;


end

