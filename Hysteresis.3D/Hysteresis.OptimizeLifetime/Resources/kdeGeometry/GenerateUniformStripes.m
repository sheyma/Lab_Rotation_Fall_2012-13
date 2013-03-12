%% settings
NumberOfDots= 150; % has to be even, for technical reasons
DistributionSigma= 0.4;   % how much more dense dots are near the pole
StripeWidth= 22.5*pi/180; % width of the individual stripe
StripesN= 0; % number of stripes, 0 for a complete sphere

%% generating Y - distribution of vertical location 
Y1= rand(1, NumberOfDots/2);
Y1(Y1>0)= -Y1(Y1>0);
Y1= Y1+1;
Y2= -rand(1, NumberOfDots/2);
Y2(Y2<0)= -Y2(Y2<0);
Y2= Y2-1;
Y= [Y1 Y2];

%% defining stripes
sA= 0:pi*2/StripesN:2*pi; % stripes center
sA(end)= [];
maxDX= sin(StripeWidth/2); % maximal x displacement at the equator
rXY= sqrt(1-Y.^2);
realA= real(asin(maxDX./rXY));

%% generating X and Z
X= [];
Z= [];
for iP= 1:NumberOfDots,
  if (StripesN==0)
    % complete sphere
    A= rand(1,1)*2*pi;
  else
    % computing real stripe angular with to keep stripe rectangular
    iS= ceil(rand(1,1)*StripesN);
    A= rand(1,1)*(realA(iP)*2)-realA(iP)+sA(iS);
  end
  X(end+1)= rXY(iP)*cos(A);
  Z(end+1)= rXY(iP)*sin(A);
end;

%% plotting
clf;
scatter3(X, Z, Y);
axis square;
axis([-1 1 -1 1 -1 1]);
xlabel('x');
ylabel('z');
zlabel('y');
axis off;
view(45, 0);

%% saving
CKDE.SaveShape(sprintf('sphere-%d.kde', NumberOfDots), X, Y, Z);