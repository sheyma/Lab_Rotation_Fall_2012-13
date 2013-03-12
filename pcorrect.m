clear all;

load('/home/sheyma/devel/Lab_Rotation_Fall_2012-13/Hysteresis.3D/Hysteresis.OptimizeLifetime/Results/sheyma.mat');


k=length(Block);

Lifetime=[1 2 3 4 8 16];
P_cor=zeros(length(Lifetime),k);
P_correct=zeros(size(Lifetime));

for j=1:k
  for i=1:numel(Lifetime)
    index=find(Block{j}.LifetimeInFrames==Lifetime(i));
    c=Block{j}.Correct(index);
    P_cor(i,j)=sum(c)/length(c);
  end
end


for i=1:numel(Lifetime)
P_correct(i)=sum(P_cor(i,:))/length(P_cor(i,:));
end


P_correct

% plot(Lifetime,P_correct)

    