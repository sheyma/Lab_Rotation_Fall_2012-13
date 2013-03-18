function WC_my_exp
clear all;
close all;


%%%%%%% plot GLF for different s values

x=0:0.01:1;
s=linspace(0,1,5);

figure(1);
hold on
plot(x, 0.5*ones(size(x)), 'k--');
plot(x,x,'k--');

    params.NU=1;
    params.ALPHA0=7.2755;
    params.ALPHA1=-0.7789;
    params.BETA=7;

for i=1:numel(s)
    plot(x,GLF_s(x,s(i),params),'r','LineWidth',2);
end
hold off
xlabel('x','FontSize',16);
ylabel('\Phi(x)','FontSize',16);
legend('s= 0, 0.25, 0.5, 0.75, 1 ', 'Location','NorthWest' );
title('GLF for different s levels','FontSize',16);

%%%%%%% plot activity x of a transient input s

DT=0.02;
T_end=1; % seconds
n_step=T_end/DT;
TAU=0.3;

T2=0.25;    % transient = DELTA-T
T3=0.25;    % T2=T_end * .8
            % T1=T_end-(T3+T2);

step_tot=round(n_step);
step2=round(T2/DT);
step3=round(T3/DT);
step1=step_tot-(step2+step3);

% coherence levels for s

c1=0;  % initial coherence value of s
c2=1;  % transient coherence value of s
c3=.4; % intermediate coherence value of s

s_exp=[c1*ones(1,step1), c2*ones(1,step2), c3*ones(1,step3)];

t_TAU=linspace(0,T_end,n_step)/TAU;

    x0=0.3;
    params.SIGMA=0.35;
    params.DT=0.02;
    params.TAU=0.3;
    params.SIGMA_P=params.SIGMA * sqrt (params.TAU);

xt=WilCow(s_exp,x0,params);

[yss_h, yss_m, yss_l]=WC_ss(s_exp);

figure(2);
hold on
plot(t_TAU,s_exp,'.k','LineWidth',2);
plot(t_TAU,xt,'r','LineWidth',2);
plot(t_TAU,yss_l,'--g','LineWidth',1);
plot(t_TAU,yss_m,'--b','LineWidth',1);
plot(t_TAU,yss_h,'--m','LineWidth',1);

% axis([0 10 0 1]);
hold off
xlabel('t/\tau (s)', 'FontSize', 16);
ylabel('x, s', 'FontSize', 16);
title('Activity x by WC model with transient s,  \tau=0.3 ', 'FontSize', 16);
legend('\Delta T (transient)=0.25 s ', 'Location','NorthWest' );


%%%%%% plot T2 vs activity probability

% 1. define different transient values (=T2)
% 2. each T2 corresponds to one "s"
% 3. for each s, find x by WilCow by 200 repeats
% 4. for each s, find P_yes and P_no

TAU=0.3;
DT=0.02;
T_end=1;
T3=0.25;
T2=linspace(.1,.5,9);       % 9 different transient values

P_YES1=zeros(size(T2));
P_YES2=zeros(size(T2));

N_repeat=200;

    x0=0;
    params.SIGMA=0.35;
    params.DT=0.02;
    params.TAU=0.3;
    params.SIGMA_P=params.SIGMA * sqrt (params.TAU);


for i=1:numel(T2)
   
    % coherence levels of transient s
    
    c1=0;
    c2=1;
    c3=0.4;
    
    tot_step=round(T_end/DT);
    step2=round(T2(i)/DT);
    step3=round(T3/DT);
    step1=tot_step - (step2 + step3);
    
    s_new=[c1*ones(1,step1) c2*ones(1,step2) c3*ones(1,step3)];
    s_noT2=[c1*ones(1,step1+step2) c3*ones(1,step3)];
    
%     t_TAU=DT*(1:tot_step)/TAU;
    
    N_YES1=0;
    N_YES2=0;
    
    for j=1:N_repeat
    
        x_new=WilCow(s_new,x0,params);
        x_noT2=WilCow(s_noT2,x0,params);
        
        if x_new(end) > 0.5
            N_YES1=N_YES1+1;
        end
        
        if x_noT2(end) > 0.5
            N_YES2 = N_YES2 + 1;
        end
        
    end
    
    P_YES1(i)= N_YES1 / N_repeat;
    P_YES2(i)= N_YES2 / N_repeat;
    
    
end

figure(3)

hold on;
plot(T2,P_YES1, 'r.','LineWidth',2);
plot(T2,P_YES1, 'r--','LineWidth',2);
plot(T2,P_YES2, 'b.','LineWidth',2);
plot(T2,P_YES2, 'b--','LineWidth',2);
hold off
axis([T2(1) T2(end) 0 1]);
xlabel('t_{transient} [s]', 'Fontsize', 16);
ylabel('P_{my models percept}', 'Fontsize', 16);
title(['\tau=' num2str(TAU)], 'Fontsize', 16);


printflag=1;
if printflag 
    print 'WC_my_exp_03' -depsc2;
end


return;




% calculate GLF for different s scalar values
% for GLF_s:  x is vector, s is scalar!!!!!!
function y=GLF_s(x,s,params)

% parameters for GLF function

params.NU=1;
params.ALPHA0=7.2755;
params.ALPHA1=-0.7789;
params.BETA=7;

% let us make alpha depended on input s 

alpha=params.ALPHA0 + (params.ALPHA1-params.ALPHA0)*s;

% now express GLF 

y=(1 + exp(-params.BETA*x + alpha)).^(-1/params.NU);

return;

% Wilson Cowan model for a given stimulus and initial point
function u=WilCow(st,u0,params)

dt = params.DT / params.TAU;
sigma= params.SIGMA_P;

u=zeros(1,numel(st));
u(1)=u0;
nt= sigma * sqrt(dt) * normrnd(0,1,size(st));
 
    % Numerical Integration 
    for i=2:numel(st)
        du=dt* (-u(i-1) + GLF_s(u(i-1), st(i-1) )) + nt(i-1);
        u(i) = u(i-1) + du;
    end
    
return

% find where GLF x=GLF_s(x) --- steady state points
function yzero=GLF_ss(xss,s)

params.NU=1;
params.ALPHA0=7.2755;
params.ALPHA1=-0.7789;
params.BETA=7;

yzero=GLF_s(xss,s,params)-xss;

return;

function [yss_hi, yss_mid, yss_lo]=WC_ss(s)
 
yss_hi=nan(size(s));
yss_mid=nan(size(s));
yss_lo=nan(size(s));

params.NU=1;
params.ALPHA0=7.2755;
params.ALPHA1=-0.7789;
params.BETA=7;

for i=1:numel(s)
    
    xss=fsolve(@(x) GLF_ss( x,s(i) ), [0.01 0.5 0.99], optimset('Display','off') );
    yss=GLF_s(xss, s(i), params);
    
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





