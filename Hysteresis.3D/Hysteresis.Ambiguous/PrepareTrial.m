%% prepare trial sequence
CoherenceLevel= repmat(Trial.Levels(iTrial, 1), 1, PrimeDurationFrames);
iLevel= 2;
RepetitionsN= ceil(ProbeDurationFrames/(2*Trial.HalfPeriodFrames(iTrial)));
for iRep= 1:RepetitionsN,
  for iLevel= 2:-1:1,
    CoherenceLevel= [CoherenceLevel repmat(Trial.Levels(iTrial, iLevel), 1, Trial.HalfPeriodFrames(iTrial))];
  end;
end;
CoherenceLevel= CoherenceLevel(1:TotalFrames);
Log.Block{end}.Trial(iTrial).InputCoherence= CoherenceLevel;
Log.Block{end}.Trial(iTrial).RealCoherence= nan(1, TotalFrames);

%% padding coherence level since at the end of the current frame with set up the next one (so we need an extra value for the final frame)
CoherenceLevel(end+1)= CoherenceLevel(end);

%% preparing stimulus
NC.Init(CoherenceLevel(1));