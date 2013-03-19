function GlogF

clear all;
close all; 


nui=-1:0.01:4;
yi=(1+nui).^(-1./nui);

% When /nu approaches to 0, limit of yi equals to 1/e (page 6!)
N=1000;
yi_limit=(N/(N+1))^N;

figure;
hold on
plot(nui,yi,'b','LineWidth',2);
plot(0,yi_limit, 'ko', 'MarkerSize', 30)
xlabel('\nu', 'FontSize', 16')
ylabel('y_{InflectionPoint}', 'Fontsize',16)
hold off

%%%%%%%%%% now let us an infl.point, assume Yinfl < 1/e

Yinfl1=0.25;
slope1=1.5;
Xinfl1=0.5;

dummy = fsolve(@(nu) GLFinfl(nu,Yinfl1), [0.1 10], optimset('Display','off'));

% now i have found nu, which satisfies GLFinfl, but it is complex!

nu1=real(dummy(1));
beta1=slope1*(1+nu1)^(1+1/nu1);
alpha1=(Xinfl1*beta1)+log(nu1);


% now let us thry another infl.point, assume Yinfl > 1/e

Yinfl2=0.75;
slope2=1.5;
Xinfl2=0.5;

dummy=fsolve(@(nu) GLFinfl(nu,Yinfl2), [0.1 10], optimset('Display','off'));

nu2=real(dummy(1));
beta2=slope2*(1+nu2)^(1+1/nu2);
alpha2=(Xinfl2*beta2)+log(nu2);


% bisection points

Xhalf1=(alpha1-log(2^nu1-1))/beta1;
Yhalf1=0.5;
Hslope1=beta1*(1-2^(-nu1))/(2*nu1);


Xhalf2=(alpha2-log(2^nu2-1))/beta2;
Yhalf2=0.5;
Hslope2=beta2*(1-2^(-nu2))/(2*nu2);


x=0:0.01:1;
eps = [-0.1 0.1];


figure;
hold on
plot(x, GLF(x, alpha1,beta1,nu1), '--r','LineWidth',2)
plot(x, GLF(x, alpha2,beta2,nu2), 'r','LineWidth',2)
% h = legend('\nu<0', '\nu>0', 'Location', 'SouthEast');
xlabel('x', 'Fontsize',16)
ylabel('GLF', 'Fontsize' ,16)

plot(Xinfl1,Yinfl1, 'ko', 'MarkerSize', 10);
plot(Xinfl1+eps, Yinfl1+slope1*eps,'k', 'LineWidth', 2);
plot(Xhalf1,Yhalf1, 'bo', 'MarkerSize', 10);
plot(Xhalf1+eps, Yhalf1+Hslope1*eps,'b', 'LineWidth', 2);

plot(Xinfl2,Yinfl2, 'ko', 'MarkerSize', 10);
plot(Xinfl2+eps, Yinfl2+slope2*eps,'k', 'LineWidth', 2);
plot(Xhalf2,Yhalf2, 'bo', 'MarkerSize', 10);
plot(Xhalf2+eps, Yhalf2+Hslope2*eps,'b', 'LineWidth', 2);

plot(x,.5*ones(numel(x)), 'k--')
plot(x,x,'k--')

hold off


%%%%%%%%%%%%%%%
clear alpha beta nu Xinfl Yinfl slope Xhalf Yhalf Hslope;

Yinfl=0.2;
slope=1.0;
Xhalf=0.55;
Yhalf=0.5;

dummy= fsolve(@(nu) GLFinfl(nu,Yinfl), [0.1 10], optimset('Display', 'Off'));
nu=real(dummy(1));
beta=slope*(1+nu)^(1+1/nu);
alpha = beta * Xhalf + log(2^nu-1);
Xinfl = (alpha - log(nu)) / (beta);
Hslope= beta*(1-2^(-nu))/(2*nu);

x=0:0.01:1;
eps=[-0.02 0.02];




figure;
hold on
plot(x,.5*ones(size(x)),'k--');
plot(x,x,'k--');
plot(x, GLF(x,alpha,beta,nu),'r','LineWidth',2);
plot(Xinfl,Yinfl,'ko', 'Markersize', 10);
plot(Xinfl+eps,Yinfl+slope*eps,'k', 'LineWidth',2);
plot(Xhalf,Yhalf,'bo', 'Markersize', 10);
plot(Xhalf+eps, Yhalf+Hslope*eps, 'b', 'LineWidth',2);


% Stationary Points
xss=fsolve(@(x) GLFss(x, alpha, beta, nu), [0.01 0.5 0.99], optimset('Display', 'off'));
% plotting stationary points
for i=1:numel(xss)
    if abs(GLF(xss(i),alpha,beta,nu)-xss(i))<0.01
        plot(xss(i), GLF(xss(i),alpha,beta,nu), 'k.', 'Markersize',10);
    end
end

% % another GFL function with different variables
Yinfl=0.2;
slope=1.5;
Xhalf=0.45;
Yhalf=0.5;

dummy= fsolve(@(nu) GLFinfl(nu,Yinfl), [0.1 10], optimset('Display', 'Off'));
nu=real(dummy(1));
beta=slope*(1+nu)^(1+1/nu);
alpha = beta * Xhalf + log(2^nu-1);
Xinfl = (alpha - log(nu)) / (beta);
Hslope= beta*(1-2^(-nu))/(2*nu);


plot(x,GLF(x,alpha,beta,nu),'r--','LineWidth',2);
plot(Xinfl,Yinfl,'ko','Markersize', 10);
plot(Xinfl+eps,Yinfl+eps*slope, 'k','LineWidth',2)
plot(Xhalf,Yhalf,'bo', 'Markersize', 10);
plot(Xhalf+eps, Yhalf+Hslope*eps, 'b', 'LineWidth',2);

% stationary points for new GLF function
xss=fsolve(@(x) GLFss(x, alpha, beta, nu), [0.01 0.5 0.99], optimset('Display', 'off'));
% plotting stationary points
for i=1:numel(xss)
    if abs(GLF(xss(i),alpha,beta,nu)-xss(i))<0.01
        plot(xss(i), GLF(xss(i),alpha,beta,nu), 'k.', 'Markersize',10);
    end
end
hold off




%%%%%%%%%%%%%%%%%%%%% different alpha valuesdepending on s

Yinf=0.5;
slop=1.5;
 
dummy=fsolve(@(nu) GLFinfl(nu,Yinf), [0.1 10], optimset('Display', 'Off'));
nu=real(dummy(1));
beta=slop*(1+nu)^(1+1/nu);

si=linspace(0,1,5);
alpha=3.6 + (2.4-3.6)*si;
Xinf=(alpha-log(nu))/beta;

figure;
hold on
plot(x,.5*ones(size(x)),'k--');
plot(x,x,'k--');

clr='rygbm';
for i=1:numel(si)
   plot(x,GLF(x,alpha(i),beta,nu), clr(i), 'LineWidth',2) 
   plot(Xinf(i),Yinf,'ko','Markersize', 12)
end

xlabel( 'x', 'FontSize', 16);
ylabel( '\Phi(x)', 'FontSize', 16);
title('\alpha changes depending on s', 'FontSize', 16)
hold off

Xhalfi=0.6 - .2* si;

figure;
hold on
plot(x,.5*ones(size(x)),'k--');
plot(x,x,'k--');

for i=1:numel(si)
    alpha(i) = beta * Xhalfi(i) + log(2^nu - 1);
    plot(x, GLF(x, alpha(i), beta, nu), clr(i), 'LineWidth', 2 );
    plot(Xhalfi(i), 0.5 ,'ko','Markersize',12)
end


xlabel( 'x', 'FontSize', 16);
ylabel( '\Phi(x)', 'FontSize', 16);
title('linear x_{half}, slope', 'FontSize', 16);

hold off


return;


function f = GLFinfl (nu, yInfl)
f = real((1+nu).^(-1./nu)-yInfl);

return;

% TRICK to make GLF all zero when it is negative
function t=GLF(x, alpha, beta, nu)
t=max(0, real((1+exp(-beta*x+alpha)).^(-1/nu)));
tmin=min(t);
index=find(t==tmin);
t(1:index(1))=tmin*ones(size(1:index(1)));
return;

% where does GLF intersects with x=y
function s=GLFss(xss, alpha, beta, nu)
s = GLF(xss, alpha, beta, nu) - xss;
return;

