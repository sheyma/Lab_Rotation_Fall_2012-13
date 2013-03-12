%% getting current block settings
Settings.SettingsForBlock(iBlock);
 
%% initializing logger
Log.NewBlock({'MeasuredFPS', 'OnsetDelay', 'LifetimeInFrames', 'LifetimeInSec', 'Direction', 'Response', 'RT', 'Correct'});
Log.Block{end}.MeasuredFPS= ptbScreen.Mode.hz;

%% service variables
CenterXY= [ptbScreen.Rect(3)/2 ptbScreen.Rect(4)/2];
FrameDuration= 1/ptbScreen.Mode.hz;
TotalFrames= round(Settings.TestLifetime.Duration/FrameDuration);

%% mixing conditions for all trials
TrialsN= numel(Settings.TestLifetime.LifetimeInFrames)*Settings.TestLifetime.RepeatCondition*2;
Trial.LifetimeInFrames= repmat(Settings.TestLifetime.LifetimeInFrames, 1, Settings.TestLifetime.RepeatCondition);
Trial.LifetimeInFrames= Trial.LifetimeInFrames(randperm(numel(Trial.LifetimeInFrames)));
Trial.LifetimeInFrames= [Trial.LifetimeInFrames Trial.LifetimeInFrames(end:-1:1)];
Dir= [-1 1];
Trial.Direction= Dir(randi(2, 1, TrialsN));

%% randomizing further aspects of trials
Trial.OnsetDelay= rand(TrialsN, 1).*(Settings.TrialDelay(2)-Settings.TrialDelay(1))+Settings.TrialDelay(1);

%% logging everything we know already
Log.Block{end}.OnsetDelay= Trial.OnsetDelay;
Log.Block{end}.LifetimeInFrames= Trial.LifetimeInFrames;
Log.Block{end}.LifetimeInSec= Trial.LifetimeInFrames.*FrameDuration;
Log.Block{end}.Direction= Trial.Direction;

%% finally, welcome to block message
Strings= {sprintf('Block %d of %d', iBlock, Settings.BlockN), 'Please report direction of rotation', 'using <LEFT> and <Right>  arrow keys', 'Press <Enter> to continue', '<Esc> to exit'};
ptbScreen.ShowCenteredMessage(Strings, [255 255 255]);
Screen('Flip', ptbScreen.WinID);
GetResponse(Settings.Keyboard.Enter, [1], Settings.Keyboard.Escape);
