%% settings
NumberOfDots= 2000; % has to be even, for technical reasons
DistributionSigma= 0.4;   % how much more dense dots are near the pole
StripeWidth= 22.5*pi/180; % width of the individual stripe
StripesN= 2; % number of stripes, 0 for a complete sphere

%% generating Y - distribution of vertical location 
Y1= normrnd(0, DistributionSigma, 1, round(NumberOfDots/3));
Y1(Y1>0)= -Y1(Y1>0);
Y1= Y1+1;
Y2= normrnd(0, DistributionSigma, 1, round(NumberOfDots/3));
Y2(Y2<0)= -Y2(Y2<0);
Y2= Y2-1;
Y= [Y1 Y2];

%% making a ring
sA= [0 pi]; % stripes center
maxDX= sin(StripeWidth/2); % maximal x displacement at the equator
rXY= sqrt(1-Y.^2);
realA= real(asin(maxDX./rXY));
X= [];
Z= [];
for iP= 1:numel(Y),
  % computing real stripe angular with to keep stripe rectangular
  iS= ceil(rand(1,1)*StripesN);
  A= rand(1,1)*(realA(iP)*2)-realA(iP)+sA(iS);
  X(end+1)= rXY(iP)*cos(A);
  Z(end+1)= rXY(iP)*sin(A);
end;

%% making two drum surfaces
DotsPerSide= (NumberOfDots-numel(Y))/2;
for xSign= [-1 1],
  Z= [Z xSign.*maxDX+zeros(1, DotsPerSide)];
  for iDot= 1:DotsPerSide,
    newY= rand(1,1)*2-1;
    newZ= rand(1,1)*2-1;
    while(hypot(newY, newZ)>1),
      newY= rand(1,1)*2-1;
      newZ= rand(1,1)*2-1;
    end;
    Y(end+1)= newY;
    X(end+1)= newZ;
  end;
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

Filename= sprintf('Drum-%04d.kde', NumberOfDots);
fprintf('%s\n', Filename);
CKDE.SaveShape(Filename, X, Y, Z);


%% plotting
clf;
scatter3(X, Z, Y);
% hold on;
% scatter3(X(iRight), Z(iRight), Y(iRight), 'ro');
% hold off;
axis square;
axis([-1 1 -1 1 -1 1]);
xlabel('x');
ylabel('z');
zlabel('y');
% axis off;
view(90, 0);
axis square;