%% random trial onset delay
Screen('FrameOval', ptbScreen.WinID, Settings.Fixation.Color, [CenterXY(1)-Settings.Fixation.Size/2 CenterXY(2)-Settings.Fixation.Size/2 CenterXY(1)+Settings.Fixation.Size/2 CenterXY(2)+Settings.Fixation.Size/2]);
Screen('Flip', ptbScreen.WinID);
WaitSecs(Trial.OnsetDelay(iTrial));

%% presenting noisy cylinder
for iFrame= 1:TotalFrames,
  %% stimulus
  Screen('BlendFunction', ptbScreen.WinID, GL_SRC_ALPHA, GL_ONE);
  NC.DrawStereoHalf(ptbScreen.WinID, CenterXY, Settings.TestLifetime.Depth_Rad, [255 0 0]);
  NC.DrawStereoHalf(ptbScreen.WinID, CenterXY, -Settings.TestLifetime.Depth_Rad, [0 255 0]);
  Screen('FrameOval', ptbScreen.WinID, Settings.Fixation.Color, [CenterXY(1)-Settings.Fixation.Size/2 CenterXY(2)-Settings.Fixation.Size/2 CenterXY(1)+Settings.Fixation.Size/2 CenterXY(2)+Settings.Fixation.Size/2]);
  Screen('BlendFunction',ptbScreen.WinID,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
  Screen(ptbScreen.WinID,'Flip');

  %% advancing NC
  NC.Advance;
end;

%% getting response
ptbScreen.ShowCenteredMessage({'<- or -> ?'}, [255 255 255]);
Screen(ptbScreen.WinID,'Flip');
[Log.Block{end}.Response(iTrial), Log.Block{end}.RT(iTrial)]= GetResponse([Settings.Keyboard.Left Settings.Keyboard.Right ], [-1 1], Settings.Keyboard.Escape);
Log.Block{end}.Correct(iTrial)= Log.Block{end}.Response(iTrial)==Trial.Direction(iTrial);