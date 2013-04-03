function Last

clear all;
close all;

global NU ISLOPE BETA ALPHA0 ALPHA1 DT TAU SIGMAPRIME

NU=1;
ISLOPE=1.5; % slope at inflection point
BETA=ISLOPE*(1+abs(NU))^(1+1/abs(NU)); % shift in sigmiods ?
TAU=0.1; % time constant of Wil-Cow. Model
sigma=0.2; %noise amplitute
SIGMAPRIME=sigma*sqrt(TAU); % effective noise amplitude


% alpha_try=linspace(3,4,50);
% alpha_try=linspace(2.2,3.2,50);  
  
  alpha_try=linspace(2.5,3.5,50);

[yss_hi, yss_mid, yss_lo] = WCss( alpha_try, BETA, NU );


k=find(~isnan(yss_hi)); % at which columns y_lo is not NaN
j=find(~isnan(yss_lo)); % at which columns y_hi is not NaN

A0=alpha_try(k(end));
A1=alpha_try(j(1));

S_LO=1/4;
S_HI=5/8;

ALPHA0 = ( A0 * S_HI - A1 * S_LO ) / (S_HI - S_LO );
ALPHA1 = ( A1 * (1-S_LO) - A0 * (1-S_HI) ) / (S_HI - S_LO );
                        
A0 = ALPHA0 + S_LO * (ALPHA1-ALPHA0);
A1 = ALPHA0 + S_HI * (ALPHA1-ALPHA0);

xss_hi1=yss_hi(k(end));
xss_hi2=yss_hi(j(1));

xss_lo1=yss_lo(k(end));
xss_lo2=yss_lo(j(1));

x=0:.01:1;

figure(1);
hold on
plot(x, GLF(x, ALPHA0, BETA, NU), 'r--', 'LineWidth',2);
plot(x, GLF(x, A0, BETA, NU), 'r--', 'LineWidth',2);
plot(x, GLF(x, ALPHA1, BETA, NU), 'r', 'LineWidth',2);
plot(x, GLF(x, A1, BETA, NU), 'r', 'LineWidth',2);

plot( xss_hi1, xss_hi1, 'k.');
plot( xss_lo1, xss_lo1, 'k.');
plot( xss_hi2, xss_hi2, 'k.');
plot( xss_lo2, xss_lo2, 'k.');

plot( x, 0.5*ones(size(x)), 'k--');
plot( x, x, 'k--');

h = legend('s=0', ['s=' num2str(S_LO,2)], ['s=' num2str(S_HI,2)], 's=1', 'Location', 'SouthEast' );
set(h,'FontSize', 16);

axis 'equal';
xlabel( 'x', 'FontSize', 16);
ylabel( '\Phi(x)', 'FontSize', 16);
title( 'Transfer function shifts with input', 'FontSize', 16);
hold off


n_lev=30;
s_level = linspace(0.1,0.9, n_lev);

[yss_hi, yss_mid, yss_lo]=WCss2(s_level);

% but those three vectors above might have NaN elements

for j=1:s_level
    if isnan(yss_hi(j))
        yss_hi(j)=min(yss_hi);
    end
    
    if isnan(yss_lo(j))
        yss_lo(j)=max(yss_lo);
    end
end
        
figure(2);
hold on
plot(s_level,yss_hi,'r','LineWidth',2);
plot(s_level,yss_mid,'b','LineWidth',2);
plot(s_level,yss_lo,'g','LineWidth',2);
xlabel('s level','FontSize',16);
ylabel('y_{hi}(red)  ,y_{mid}(blue),  y_{lo}(green)','FontSize',16);
title('Steady States with changing external input s', 'FontSize', 16);
hold off





return;





% 1... GLF, for nu>=1 and nu<1, CONSTANT STIM
function y=GLF(x,alpha,beta,nu)

    if nu>=1
        y=(1+exp(-beta.*x+alpha)).^(-1/nu);
    elseif nu<-1
        y=1-(1+exp(-beta.*(1-x)+alpha)).^(-1/nu);
    end
    
return;


%2... GLF, alpha depends on s!
function y = GLDF2D(x,s)
% x and y are vectors, s is scalar
global NU BETA ALPHA0 ALPHA1
beta=BETA;
nu=NU;
alpha = ALPHA0 + (ALPHA1-ALPHA0)*s;

y=(1+exp(-beta.*x+alpha)).^(-1/nu);
return;

%3... steady state points' fucntion
function yzero=GLFss(xss,alpha,beta,nu)
yzero=GLF(xss,alpha,beta,nu)-xss;
return;

%4... run Wilson-Cowan Model
function u=WCrun(st,u0)
global DT TAU SIGMAPRIME
u=zeros(size(st));
dt1=DT/TAU;
dt2=SIGMAPRIME*sqrt(DT)/TAU;

    if SIGMAPRIME > 0
        nt=normrnd(0,1,size(st));
        for i=1:numel(st)
            u(i)=u0+dt1*(-u0+ GLF2D(u0,st(i)))+dt2*nt(i);
            u0=u(i);
        end
    else
        for i=1:numel(st)
            u(i)=u0+dt1*(-u0+ GLF2D(u0,st(i)));
            u0=u(i);
        end
    end
return;

%5... find state states of Wil-Cow Model for CONST. STIM.
function [yss_hi, yss_mid, yss_lo] = WCss (alpha, beta, nu)
% beta,nu -- constants; alpha is a vector
yss_hi=nan(size(alpha));
yss_mid=nan(size(alpha));
yss_lo=nan(size(alpha));

for i=1:numel(alpha)
    
    if nu>=1

xss=fsolve(@(x) GLFss(x,alpha(i),beta,nu), [0.01 0.5 0.99], optimset('Display', 'off'));
yss=GLF(xss,alpha(i),beta,nu);
    else
xss=fsolve(@(x) GLFss(x,alpha(i),beta,nu), [0.99 0.5 0.01], optimset('Display', 'off'));
yss=GLF(xss,alpha(i),beta,nu);        
    end
    
    %label ss points
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

%6... now insert directly "s" into steady state function
function [yss_hi, yss_mid, yss_lo]=WCss2(s_lev)
 % s is a vector
yss_hi=nan(size(s_lev));
yss_mid=nan(size(s_lev));
yss_lo=nan(size(s_lev));

global NU BETA ALPHA0 ALPHA1

nu=NU;
beta=BETA;
alpha= ALPHA0 + (ALPHA1 - ALPHA0) *s_lev;

for i=1:numel(s_lev)
    
    if nu>=1

xss=fsolve(@(x) GLFss(x,alpha(i),beta,nu), [0.01 0.5 0.99], optimset('Display', 'off'));
yss=GLF(xss,alpha(i),beta,nu);
    else
xss=fsolve(@(x) GLFss(x,alpha(i),beta,nu), [0.99 0.5 0.01], optimset('Display', 'off'));
yss=GLF(xss,alpha(i),beta,nu);        
    end
    
    %label ss points
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
 




    
