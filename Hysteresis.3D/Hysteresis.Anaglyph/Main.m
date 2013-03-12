clear all;
CaughtException= [];

%% general settings 
Folder.Settings= 'Settings/'; % path to settings folder 

%% asking for user name
%    ObserverName= 'jl_t2'; %has to be the same as the name of the setting-file (.exp) 
% ObserverName= 'cy_e';   
if (~exist('ObserverName', 'var') || isempty(ObserverName))
  ObserverName= input('Please enter your name: ', 's');
end;

%% initializing book-keeping utilities
try 
  Settings= CExperimentalSettings(ObserverName, Folder.Settings);
catch exception
  if (~strcmp(exception.identifier, 'CExperimentalSettings:ErrorReadingFile'))
    rethrow(exception);
  end;
end;

Folder.Results= 'Results/';   % path to results folder

%%
try
  %% generating log file name
  LogFileName= ObserverName;
  Log= CLog(LogFileName, Folder.Results);
 
  %% initializing PTB screen 
  ptbScreen= CPTBScreen(Settings.Screen);
  
  %% preparing stimuli
  NC= CNoisyCylinder(ptbScreen.Mode, Settings.NoisyCylinder);
 
  %% cutting out extra controls
  if (Settings.Screen.FullScreen)
    HideCursor;
    ListenChar(2); %% cut-off matlab from key presses
  end;
    
  %% going through blocks
  for iBlock= 1:Settings.BlockN,
    %% preparing block
    PrepareBlock;
 
    %% running block
    for iTrial= 1:TrialsN,
      PrepareTrial;
      RunTrial;
    end
    
    %% saving collected data
    Log.Save(Settings.Current);
  end;
catch exception
  if (~strcmp(exception.identifier, 'Experiment:Abort'))
    CaughtException= exception;
  end;
end;

%% closing PTB
ListenChar(0); %% re-enable matlab to see key presses
if (exist('ptbScreen', 'var'))
  ptbScreen.Close;
  ShowCursor;
end;

%% rethrowing exception if we have one
if (~isempty(CaughtException))
  rethrow(CaughtException);
end