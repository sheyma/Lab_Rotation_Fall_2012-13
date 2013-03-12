%% prepare trial sequence
CoherenceLevel= [repmat(Trial.Levels(iTrial, 1), 1, PrimeDurationFrames) repmat(Trial.Levels(iTrial, 2), 1, ProbeDurationFrames)];
Log.Block{end}.Trial(iTrial).InputCoherence= CoherenceLevel;
Log.Block{end}.Trial(iTrial).RealCoherence= nan(1, TotalFrames);

%% padding coherence level since at the end of the current frame with set up the next one (so we need an extra value for the final frame)
CoherenceLevel(end+1)= CoherenceLevel(end);

%% preparing stimulus
NC.Init(CoherenceLevel(1), Settings.Hysteresis.SignalVelocity);