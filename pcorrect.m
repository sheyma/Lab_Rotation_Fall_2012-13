clear all;
close all;
% P_correct (==P_t) versus LifetimeinFrames

% Loading data from observer : Sheyma Bayrak
load('/Users/seyma/GIT/Lab_Rotation_Fall_2012-13/Hysteresis.3D/Hysteresis.OptimizeLifetime/Results/sheyma.mat');

% How manx cells of data I have from the experiment
k=length(Block);


Lifetime=[1 2 3 4 8 16];
N=k*(numel(Block{1}.Correct)/numel(Lifetime));


N_cor=zeros(length(Lifetime),k);
N_cor_tot=zeros(size(Lifetime));

for j=1:k
  for i=1:numel(Lifetime)
    index=find(Block{j}.LifetimeInFrames==Lifetime(i));
    c=Block{j}.Correct(index);
    N_cor(i,j)=sum(c);
  end
end


for i=1:numel(Lifetime)
N_cor_tot(i)=sum(N_cor(i,:));
end


%P_t can be negative, it should be avoided for binofit function

P_t=abs(2*(N_cor_tot/N)-1);
 
 
[phit, pci]=binofit(P_t*N,N);

figure;
hold on
plot((Lifetime),phit,'--o','MarkerSize',8);
 axis([0 17 0 1])
for j=1:numel(Lifetime)
    plot((Lifetime(j)),linspace(pci(j,1),pci(j,2)));
end
hold off
xlabel('Lifetime in Frames','Fontsize',16);
ylabel('P_t','Fontsize',16);
title('Perceprion in Fraction as Lifetime of Dots','Fontsize',16);

    