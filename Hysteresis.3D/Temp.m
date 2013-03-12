tic;
Vsignal= 0.2;
N= 100;
a= rand(N, 1);
b= rand(N, 1).*(1-a);
c= rand(N, 1).*(1-a-b);
W= sqrt(a.^2+b.^2+c.^2);
Vtemp= Vsignal./W

Vxyz= nan(N, 3);
for iDot= 1:N,
  Vxyz(iDot, :)= Vtemp(iDot).*[a(iDot) b(iDot) c(iDot)];
end;
toc;
% sqrt(Vxyz(:, 1).^2+Vxyz(:, 2).^2+Vxyz(:, 3).^2)


% function [r, a, x]= GenerateCoordsWithinCylinder(N)
%   
%   %% generating dots with UNIFORM distribution, but make sure they are all within radius=1
%   XY= rand(N, 2)*2-1;
%   r= hypot(XY(:, 1), XY(:, 2));
%   iOutside= find(r>1);
%   while (~isempty(iOutside)),
%     XY(iOutside, :)= rand(numel(iOutside), 2)*2-1;
%     r(iOutside)= hypot(XY(iOutside, 1), XY(iOutside, 2));
%     iOutside= find(r>1);
%   end;
% 
%   %% figuring the angle to go with it
%   a= atan2(XY(:, 2), XY(:, 1));
%   