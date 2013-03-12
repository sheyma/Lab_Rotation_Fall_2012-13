clear all;

%% loading observers
Observer= LoadObservers('sheyma', 'sheyma');

%% figuring out all lifetime durations
AllLifetimes= [];
for iO= 1:numel(Observer),
  Observer(iO).AllCoherence= [];
  Observer(iO).AllCorrect= [];
  for iB= 1:numel(Observer(iO).Block),
    Observer(iO).AllCoherence= [ Observer(iO).AllCoherence Observer(iO).Block{iB}.LifetimeInFrames];
    Observer(iO).AllCorrect= [Observer(iO).AllCorrect Observer(iO).Block{iB}.Correct];
  end;
  AllLifetimes= [AllLifetimes unique(Observer(iO).AllCoherence)];
end;
Lifetime= sort(unique(AllLifetimes));

%% computing average for each observer
Correct= nan(numel(Observer), numel(Lifetime));
for iO= 1:numel(Observer),
  for iL= 1:numel(Lifetime),
    iCurrent= find(Observer(iO).AllCoherence==Lifetime(iL));
    Correct(iO, iL)= mean(Observer(iO).AllCorrect(iCurrent));
  end;
end;
  
%% plotting results
clf;
errorbar(Lifetime, nanmean(Correct), nanstd(Correct)./sqrt(numel(Observer)), 'b-o');
set(gca, 'XTick', Lifetime);
xlabel('Lifetime, frames');
ylabel('Performance');
