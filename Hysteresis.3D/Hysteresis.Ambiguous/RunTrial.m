%% random trial onset delay
Screen('FrameOval', ptbScreen.WinID, Settings.Fixation.Color, [CenterXY(1)-Settings.Fixation.Size/2 CenterXY(2)-Settings.Fixation.Size/2 CenterXY(1)+Settings.Fixation.Size/2 CenterXY(2)+Settings.Fixation.Size/2]);
Screen('Flip', ptbScreen.WinID);
WaitSecs(Trial.OnsetDelay(iTrial));

%% presenting noisy cylinder
for iFrame= 1:TotalFrames,
  %% stimulus
  NC.Draw(ptbScreen.WinID, CenterXY);
  Screen('FrameOval', ptbScreen.WinID, Settings.Fixation.Color, [CenterXY(1)-Settings.Fixation.Size/2 CenterXY(2)-Settings.Fixation.Size/2 CenterXY(1)+Settings.Fixation.Size/2 CenterXY(2)+Settings.Fixation.Size/2]);
  Screen(ptbScreen.WinID,'Flip');

  %% advancing NC
  NC.Advance(CoherenceLevel(iFrame+1));
  Log.Block{end}.Trial(iTrial).RealCoherence(iFrame)= NC.GetRealCoherence;
end;

%% getting response
ptbScreen.ShowCenteredMessage({'?'}, [255 255 255]);
Screen(ptbScreen.WinID,'Flip');
[Log.Block{end}.Response(iTrial), Log.Block{end}.RT(iTrial)]= GetResponse([Settings.Keyboard.Left Settings.Keyboard.Right Settings.Keyboard.Down Settings.Keyboard.Up], [0 1 0.5 0.5], Settings.Keyboard.Escape);
