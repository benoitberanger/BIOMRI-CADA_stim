function Plot( self )

ScreenWidth  = self.ScreenWidth;
ScreenHeight = self.ScreenHeight;

nSquareWidth = self.nSquareWidth;


Square_Wide_tempo = ...
    ScreenWidth/nSquareWidth;
X = 0 : Square_Wide_tempo : ScreenWidth - Square_Wide_tempo ;
Y = 0 : Square_Wide_tempo : ScreenHeight - Square_Wide_tempo ;

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

% Checkerboard 1
figure('Name','Checkerboard 1 visualisation','NumberTitle','off','units','normalized','OuterPosition',[0 0.03 1 0.97])
hold all
rectangle('Position',[min(X) min(Y) ScreenWidth ScreenHeight],... % This rectangle represent the screen
    'LineWidth',6,'LineStyle','-','EdgeColor','red')
for k = 1:length(Squares_Xpos1) % Loop to plot all the squares of the checkerboard
    rectangle('Position',[Squares_Xpos1(k) Squares_Ypos1(k) Square_Wide_tempo Square_Wide_tempo],...
        'LineWidth',1,'LineStyle','-','FaceColor','black')
end

set(gca,'YDir','reverse')
set(gca, 'XAxisLocation', 'top')
ylabel('<---- : Y')

xlabel('X : ---->')
axis tight

% Checkerboard 2
figure('Name','Checkerboard 2 visualisation','NumberTitle','off','units','normalized','OuterPosition',[0 0.03 1 0.97])
hold all
rectangle('Position',[min(X) min(Y) ScreenWidth ScreenHeight],... % This rectangle represent the screen
    'LineWidth',6,'LineStyle','-','EdgeColor','red')
for k = 1:length(Squares_Xpos1) % Loop to plot all the squares of the checkerboard
    rectangle('Position',[Squares_Xpos2(k) Squares_Ypos2(k) Square_Wide_tempo Square_Wide_tempo],...
        'LineWidth',1,'LineStyle','-','FaceColor','black')
end
set(gca,'YDir','reverse')
set(gca, 'XAxisLocation', 'top')
ylabel('<---- : Y')

xlabel('X : ---->')
axis tight

end % function
