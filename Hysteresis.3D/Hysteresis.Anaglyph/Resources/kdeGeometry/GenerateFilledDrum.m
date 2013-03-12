%% settings
NumberOfDots= 500; % has to be even, for technical reasons
StripeWidth= 0.2; % width of the individual stripe

%% generating XYZ - distribution of vertical location 
Y= rand(1,NumberOfDots).*2-1;
X= rand(1,NumberOfDots).*2-1;
D= hypot(Y,X);
while (sum(D>1)>0),
  iBad= find(D>1);
  Y(iBad)= rand(1, numel(iBad)).*2-1;
  X(iBad)= rand(1, numel(iBad)).*2-1;
  D= hypot(Y,X);
end;
Z= rand(1, NumberOfDots)*StripeWidth*2-StripeWidth;

%% saving
Filename= sprintf('FilledDrum-%04d.kde', NumberOfDots);
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