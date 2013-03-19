function WilsonCowan
clear all;

DT=0.01;
TAU=0.01;
SIGMA=0.02;

%%%% set different s values and observe GLF

params.NU=1;
params.BETA=6;
params.ALPHA0=3.6;
params.ALPHA1=1.8;

x=0:.01:1;
s=linspace(0,1,5);

figure(1);
clf;
hold on
plot(x,0.5*ones(numel(x)),'k--');
plot(x,x,'k--');

clr='rymkb';
for i=1:numel(s)
   plot(x,GLFview(x,s(i), params),clr(i),'linewidth',2);
end

axis 'equal';
title('GLF functions with 5 different s', 'Fontsize',16)
xlabel( 'x', 'FontSize', 16);
ylabel( '\Phi(x)', 'FontSize', 16);

hold off


%%%% ramp input

x0=0.3;
Tend=5;
n_step=Tend/DT;

st=[linspace(0,1,n_step) linspace(1,0,n_step)];
tt = DT * (1:numel(st)) / TAU;
xt =WilCow( st, x0, DT, TAU, SIGMA );

figure(2);
clf;
hold on
plot(tt,st, 'k.', 'LineWidth',1);
plot(tt,xt,'r', 'LineWidth',2);

[yss_hi, yss_mid, yss_lo] = WilCowSS( st );
plot( tt, yss_hi, 'b--', 'LineWidth', 1 );
plot( tt, yss_mid, 'k--', 'LineWidth', 1 );
plot( tt, yss_lo, 'g--', 'LineWidth', 1 );

title( 'Wilson-Cowan with SS Points', 'FontSize', 16);
axis([tt(1) tt(end) 0 1]);
xlabel( 't/\tau', 'FontSize', 16);
ylabel( 'x_{steady state}', 'FontSize', 16);
hold off


%%%%%%%% flat input

x0=0;
s0=0;
s1=0.6;

Tend=1;
nstep=Tend/DT;

st=[s0*ones(1,nstep) s1*ones(1,nstep)];

tt=DT * (1:numel(st))/TAU;
xt=WilCow(st,x0,DT,TAU,SIGMA);

figure(3);
clf;
hold on
plot(tt,st,'k.','LineWidth',1);
plot(tt,xt,'r','LineWidth',2);


[yss_hi, yss_mid, yss_lo] = WilCowSS( st );
plot( tt, yss_hi, 'b--', 'LineWidth', 1 );
plot( tt, yss_mid, 'k--', 'LineWidth', 1 );
plot( tt, yss_lo, 'g--', 'LineWidth', 1 );

axis([tt(1) tt(end) 0 1]);
xlabel( 't/\tau', 'FontSize', 16);
ylabel( ' s', 'FontSize', 16);
title('Wilson-Cowan Model with Flat Input','FontSize',16);

hold off





%%%%%square wave input

x0=0;
s0=0;
s1=0.6;

Tend=1;
nstep=Tend/DT;
istep=10*TAU/DT;

st=s0*ones(1,2*nstep);

for i=1:numel(st)
    if mod( floor (i/istep), 2 )==1
        st(i)=s1;
    end
end

tt=DT * (1:numel(st))/TAU;
xt=WilCow(st,x0,DT,TAU,SIGMA);

figure(4);
clf;
hold on
plot(tt,st,'k.','LineWidth',1);
plot(tt,xt,'r','LineWidth',2);

[yss_hi, yss_mid, yss_lo] = WilCowSS( st );
plot( tt, yss_hi, 'b--', 'LineWidth', 1 );
plot( tt, yss_mid, 'k--', 'LineWidth', 1 );
plot( tt, yss_lo, 'g--', 'LineWidth', 1 );

axis([tt(1) tt(end) 0 1]);
xlabel( 't/\tau', 'FontSize', 16);
ylabel( 'x, s', 'FontSize', 16);
title('W-C Model with Square Wave Input','FontSize',16);
hold off


return;


function y=GLFview(x,s, params)

params.NU=1;
params.BETA=6;
params.ALPHA0=3.6;
params.ALPHA1=1.8;

% make alpha depended on input s
alpha=params.ALPHA0 + (params.ALPHA1 - params.ALPHA0)*s;

% now express GLF function
y=(1+exp(-params.BETA*x+alpha)).^(-1/params.NU);

return;

function u=WilCow(st,x0,dt,TAU,SIGMA)
% Wilson-Cowan Model, numerical integ. to solve u

dt=dt/TAU;
u=zeros(1,numel(st));
u(1)=x0;
nt = SIGMA * sqrt(dt) * normrnd(0,1,size(st));

for i=2:numel(st)
    du= dt * (-u(i-1) + GLFview ( u(i-1), st(i-1) ) ) + nt(i-1);
    u(i)=u(i-1)+du;
end

return;

function yzero=GLFviewSS(xss, s)
% define a zero equivalent function for stead. st. point calculation
params.NU=1;
params.BETA=6;
params.ALPHA0=3.6;
params.ALPHA1=1.8;
% when GLF intersects with x=y : 
yzero= GLFview(xss,s,params)-xss; 
return;


function [yss_hi, yss_mid, yss_lo]=WilCowSS(st)

    yss_hi = nan(size(st));   %%last ss point of one GLF (sigmoid)
    yss_lo = nan(size(st));   %%first ss point of one GLF (sigmoid)
    yss_mid = nan(size(st));  %%intm. ss point of one GLF (sigmoid)

    params.NU=1;
    params.BETA=6;
    params.ALPHA0=3.6;
    params.ALPHA1=1.8;
    
  for i=1:numel(st)
    xss=fsolve(@(x) GLFviewSS(x, st(i)), [0.01 0.5 0.99],optimset('Display','off'));
    yss=GLFview(xss, st(i), params);
    
    if abs(yss(1)-xss(1)) < 0.01    
        yss_lo(i) = yss(1);
    end
    if abs(yss(2)-xss(2)) < 0.01       
        yss_mid(i) = yss(2);
    end
    if abs(yss(3)-xss(3)) < 0.01   
        yss_hi(i) = yss(3);
    end   
    


  end
return;


