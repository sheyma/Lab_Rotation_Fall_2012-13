%% settings
NumberOfDots= 500; % has to be even, for technical reasons
DistributionSigma= 0.4;   % how much more dense dots are near the pole
StripeWidth= 22.5*pi/180; % width of the individual stripe
StripesN= 2; % number of stripes, 0 for a complete sphere

%% generating Y - distribution of vertical location 
Y1= normrnd(0, DistributionSigma, 1, NumberOfDots/2);
Y1(Y1>0)= -Y1(Y1>0);
Y1= Y1+1;
Y2= normrnd(0, DistributionSigma, 1, NumberOfDots/2);
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

% %% turning one stripe by a predifined angle
% iLeft= find(X<=0);
% iRight= find(X>=0);
% Rs= hypot(X(iRight), Z(iRight));
% As= atan2(Z(iRight), X(iRight));
% CorrectedAs= As+pi/4;
% X(iRight)= Rs.*cos(CorrectedAs);
% Z(iRight)= Rs.*sin(CorrectedAs);

% 
%% saving
% Filename= sprintf('angledstripes-%d-%04d.kde4', StripesN, NumberOfDots);
% disp(Filename);
% SphereFile= fopen(Filename, 'w');
% fprintf(SphereFile, '%g %g %g 0\n', [X; Y; Z]);
% fclose(SphereFile);

% Filename= sprintf('Band-%d-%04d.kde', StripesN, NumberOfDots);
% fprintf('%s\n', Filename);
% CKDE.SaveShape(Filename, X, Y, Z);


%% plotting
clf;
scatter3(X, Z, Y);
axis square;
axis([-1 1 -1 1 -1 1]);
xlabel('x');
ylabel('z');
zlabel('y');
axis off;
view(55, 0);