clear all;
close all;

load('/Users/seyma/GIT/Lab_Rotation_Fall_2012-13/Hysteresis.3D/Hysteresis.OptimizeLifetime/Results/sheyma.mat');


k=length(Block);


Lifetime=[1 2 3 4 8 16];
N=k*(numel(Block{1}.Correct)/numel(Lifetime));


P_cor=zeros(length(Lifetime),k);
N_correct=zeros(size(Lifetime));

for j=1:k
  for i=1:numel(Lifetime)
    index=find(Block{j}.LifetimeInFrames==Lifetime(i));
    c=Block{j}.Correct(index);
    P_cor(i,j)=sum(c);
  end
end


for i=1:numel(Lifetime)
    N_correct(i)=sum(P_cor(i,:));
    
end


%P_t can be negative, it should be avoided for binofit function

P_t=abs(2*(N_correct/N)-1);


[phit, pci]=binofit(P_t*N,N)




hold on
plot((Lifetime),phit,'--o','MarkerSize',8);
 axis([0 17 0 1])
for j=1:numel(Lifetime)
    plot((Lifetime(j)),linspace(pci(j,1),pci(j,2)));
end
hold off
xlabel('Lifetime in Frames','Fontsize',16);
ylabel('P_t','Fontsize',16);

% plot(Lifetime,P_correct)

    