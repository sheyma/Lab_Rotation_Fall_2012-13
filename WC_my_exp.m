function WC_my_exp
clear all;
close all;

% time constant for Wilson-Cowan Model
TAU=0.1;
x0=0;
SIGMA=0.02;
DT=0.01;  % seconds

%%%% transient input


T_end=1; % seconds
n_step=T_end/DT;

T1=.5;    % T1=T_end * .5
T2=.8;    % T2=T_end * .8
DELTA_T=(T2-T1); % DELTA_T=(T2-T1)*T_end = 0.3 sec;


step1=round(n_step*T1);
step2=round(n_step*DELTA_T);
step3=round(n_step*(1-T2));

%coherence levels for s
c1=0;
c2=1;
c3=.4;

s=[c1*ones(1,step1), c2*ones(1,step2), c3*ones(1,step3)];

xt=WilCow(s,x0,DT,TAU,SIGMA);

t_TAU=linspace(0,T_end,n_step)/TAU;

[yss_h, yss_m, yss_l]=WC_ss(s);

hold on
plot(t_TAU,s,'.k','LineWidth',2);
plot(t_TAU,xt,'r','LineWidth',2);
plot(t_TAU,yss_l,'--g','LineWidth',1);
plot(t_TAU,yss_m,'--b','LineWidth',1);
plot(t_TAU,yss_h,'--m','LineWidth',1);

axis([0 10 0 1]);
hold off
xlabel('t/\tau (s)', 'FontSize', 16);
ylabel('x, s', 'FontSize', 16);
title('Activity x by WC model with transient s', 'FontSize', 16);
legend('\Delta T=0.3 s', 'Location','NorthWest' );

return;


% for GLF:  x is vector, s is scalar!!!!!!
function y=GLF(x,s,params)

% parameters for GLF function

params.NU=1;
params.BETA=6;
params.ALPHA0=3.6;
params.ALPHA1=1.8;

% let us make alpha depended on input s 

alpha=params.ALPHA0 + (params.ALPHA1-params.ALPHA0)*s;

% now express GLF 

y=(1 + exp(-params.BETA*x + alpha)).^(-1/params.NU);

return;


function u=WilCow(st,u0,dt,TAU,SIGMA)
dt=dt/TAU;
u=zeros(1,numel(st));
u(1)=u0;
nt= SIGMA * sqrt(dt) * normrnd(0,1,size(st));
 
    % Numerical Integration 
    for i=2:numel(st)
        du=dt* (-u(i-1) + GLF(u(i-1), st(i-1) )) + nt(i-1);
        u(i) = u(i-1) + du;
    end
    
return

% find where GLF x=GLF(x) --- steady state points
function yzero=GLF_ss(xss,s)

params.NU=1;
params.BETA=6;
params.ALPHA0=3.6;
params.ALPHA1=1.8;

yzero=GLF(xss,s,params)-xss;

return;

function [yss_hi, yss_mid, yss_lo]=WC_ss(s)
 
yss_hi=nan(size(s));
yss_mid=nan(size(s));
yss_lo=nan(size(s));

params.NU=1;
params.BETA=6;
params.ALPHA0=3.6;
params.ALPHA1=1.8;

for i=1:numel(s)
    
    xss=fsolve(@(x) GLF_ss( x,s(i) ), [0.01 0.5 0.99], optimset('Display','off') );
    yss=GLF(xss, s(i), params);
    
    if abs(yss(1) - xss(1)) < 0.01
        yss_lo(i)=yss(1);
    end
    
    if abs(yss(2) - xss(2)) < 0.01
        yss_mid(i)=yss(2);
    end
    
    if abs(yss(3) - xss(3)) < 0.01
        yss_hi(i)=yss(3);
    end

end

return;





