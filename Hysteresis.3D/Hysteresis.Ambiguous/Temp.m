clear NC;
CenterXY= [ptbScreen.Rect(3)/2 ptbScreen.Rect(4)/2];
NoisyCylinder.Width= 300;
NoisyCylinder.Height= 300;
NoisyCylinder.Speed= 1.0; %% Hz
NoisyCylinder.SignalDirection= 0;
NoisyCylinder.DotsN= 100;
NoisyCylinder.Dot.Radius= 2;
NoisyCylinder.Dot.Lifetime= 0.72; % seconds
NoisyCylinder.Dot.RGB= [255 255 255];

NC= CNoisyCylinder(ptbScreen.Mode, NoisyCylinder);
NC.Init(1.0);

for iFrame= 1:400,
  NC.Draw(ptbScreen.WinID, CenterXY);
  Screen('Flip', ptbScreen.WinID);
  NC.Advance;
end;


