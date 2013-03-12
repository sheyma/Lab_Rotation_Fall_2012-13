clear all;

load('/home/sheyma/devel/Lab_Rotation_Fall_2012-13/Hysteresis.3D/Hysteresis.OptimizeLifetime/Results/sheyma.mat');


k=length(Block);


Lifetime=[1 2 3 4 8 16];
N=k*(numel(Block{1}.Correct)/numel(Lifetime));


P_cor=zeros(length(Lifetime),k);
P_correct=zeros(size(Lifetime));

for j=1:k
  for i=1:numel(Lifetime)
    index=find(Block{j}.LifetimeInFrames==Lifetime(i));
    c=Block{j}.Correct(index);
    P_cor(i,j)=sum(c);
  end
end


for i=1:numel(Lifetime)
    P_correct(i)=sum(P_cor(i,:));
    
end


[phit, pci]=binofit(P_correct,N);



hold on
plot(Lifetime,phit,'--o','MarkerSize',8);
axis([0 17 0 1])
for j=1:numel(Lifetime)
    plot(Lifetime(j),linspace(pci(j,1),pci(j,2)));
end



hold off



% plot(Lifetime,P_correct)

    