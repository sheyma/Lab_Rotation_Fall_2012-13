%% getting current block settings
Settings.SettingsForBlock(iBlock);
 
%% initializing logger
Log.NewBlock({'MeasuredFPS', 'OnsetDelay', 'Trial', 'HalfPeriod', 'HalfPeriodInFrames', 'Levels', 'Response', 'RT'});
Log.Block{end}.MeasuredFPS= ptbScreen.Mode.hz;

%% service variables
CenterXY= [ptbScreen.Rect(3)/2 ptbScreen.Rect(4)/2];
FrameDuration= 1/ptbScreen.Mode.hz;
PrimeDurationFrames= round(Settings.Hysteresis.PrimeDuration/FrameDuration);
ProbeDurationFrames= round(Settings.Hysteresis.ProbeDuration/FrameDuration);
TotalFrames= PrimeDurationFrames+ProbeDurationFrames;

%% mixing conditions for all trials
TrialsN= numel(Settings.Hysteresis.HalfPeriodDuration)*Settings.Hysteresis.RepeatCondition;
Trial.HalfPeriod= repmat(Settings.Hysteresis.HalfPeriodDuration, Settings.Hysteresis.RepeatCondition, 1);
Trial.Levels= nan(TrialsN, 2);
Trial.Levels(:, 1)= repmat(Settings.Hysteresis.StartLevel, 1, Settings.Hysteresis.RepeatCondition);
Trial.Levels(:, 2)= repmat(Settings.Hysteresis.OtherLevel, 1, Settings.Hysteresis.RepeatCondition);
iShuffle= randperm(TrialsN);
Trial.HalfPeriod= Trial.HalfPeriod(iShuffle);
for iLevel= 1:2,
  Trial.Levels(:, iLevel)= Trial.Levels(iShuffle, iLevel);
end;
Trial.HalfPeriodFrames= round(Trial.HalfPeriod/FrameDuration);

%% randomizing further aspects of trials
Trial.OnsetDelay= rand(TrialsN, 1).*(Settings.TrialDelay(2)-Settings.TrialDelay(1))+Settings.TrialDelay(1);

%% logging everything we know already
Log.Block{end}.OnsetDelay= Trial.OnsetDelay;
Log.Block{end}.HalfPeriod= Trial.HalfPeriod;
Log.Block{end}.HalfPeriodInFrames= Trial.HalfPeriodFrames;
Log.Block{end}.Levels= Trial.Levels;

%% finally, welcome to block message
Strings= {sprintf('Block %d of %d', iBlock, Settings.BlockN), 'Please report perception at the end of the trial', '<Right> if you saw a rotating cylinder FOR THE ENTIRE DURATION of the trial', '<Left> if you saw noise only FOR THE ENTIRE DURATION of the trial', '<Down> or <Up> if your perception alternated between the two', 'Press <Enter> to continue', '<Esc> to exit'};
ptbScreen.ShowCenteredMessage(Strings, [255 255 255]);
Screen('Flip', ptbScreen.WinID);
GetResponse(Settings.Keyboard.Enter, [1], Settings.Keyboard.Escape);
