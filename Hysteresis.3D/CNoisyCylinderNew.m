classdef CNoisyCylinder < handle 
  properties (SetAccess=protected)
    Settings        %% all the settings
    AngularVelocity   %% maximal speed (deg per frame)
    Coords          %% dots' coordinates
    SignalSpeed     %% dots' speed matrix
    Speed           %% dots' speed matrix
    SpeedX_Hz, SpeedY_Hz, SpeedZ_Hz    %% dots' speed triplet
    xyzShift
    
    
    SignalDirection
    Size            %% size of the cylinder (pixels)

    Signal2Noise
    
    trueR           %% true radius
    trueA           %% true angle of rotation
    Dir             %% direction of dots' motion
    
    ShouldBeSignal  %% whether dot should become a single or noise (in future life)
    IsSignal        %% whether dot is a signal or noise (in current life) IsSignal does not have to match ShouldBeSignal 
    
    
    Shift           %% shift for noise
    LifeLeft        %% 
    XY 
    
   
    DotSize         %% size of EACH dot at CURRENT moment
    DotRGB          %% RGB of EACH dot at CURRENT moment
    LifetimeInFrames
    
    ScreenMode 
  end
    
  methods 
    %% constructor
    function [obj]= CNoisyCylinder(CurrentScreenMode, Settings)
      % resetting all variables
      obj.Settings= Settings;
      obj.ScreenMode= CurrentScreenMode;

      % size and rotation speed
      if (~isfield(obj.Settings, 'Height'))
        obj.Settings.Height= obj.Settings.Width;
      end;      
      obj.Size= obj.Settings.Height;
      obj.AngularVelocity= obj.Settings.Speed/obj.ScreenMode.hz;
      obj.SignalDirection= obj.Settings.SignalDirection;
      
      % individual dots
      obj.DotSize= repmat([-obj.Settings.Dot.Radius -obj.Settings.Dot.Radius obj.Settings.Dot.Radius obj.Settings.Dot.Radius], obj.Settings.DotsN, 1);
      obj.DotRGB= repmat(obj.Settings.Dot.RGB, obj.Settings.DotsN, 1)';
      obj.LifetimeInFrames= round(obj.Settings.Dot.Lifetime*obj.ScreenMode.hz);
      
      % filling coordinates with nans
      obj.IsSignal= nan(obj.Settings.DotsN, 1);
      obj.trueA= nan(obj.Settings.DotsN, 1);
      obj.Dir= nan(obj.Settings.DotsN, 1);
      obj.XYZ= nan(obj.Settings.DotsN, 3);
      obj.Shift= nan(obj.Settings.DotsN, 1);
      obj.LifeLeft= zeros(obj.Settings.DotsN, 1);
    end  
    
    %% preparing first sequence
    function [obj]= Init(obj, InitialSignal2Noise, SignalDirection)
      obj.SetSignal2Noise(InitialSignal2Noise);
      obj.LifeLeft= zeros(obj.Settings.DotsN, 1);
      obj.Regenerate;
      GradedLife= repmat(1:obj.LifetimeInFrames, 1, ceil(obj.Settings.DotsN/obj.LifetimeInFrames))';
      obj.LifeLeft(1:obj.Settings.DotsN, 1)= GradedLife(1:obj.Settings.DotsN, 1);
      obj.IsSignal= zeros(obj.Settings.DotsN, 1);
    end
    
    %% setting new signal-to-noise ratio
    function [obj]= SetSignal2Noise(obj, NewSignal2Noise)
      obj.Signal2Noise= NewSignal2Noise;
      obj.ShouldBeSignal= zeros(obj.Settings.DotsN, 1);
      obj.ShouldBeSignal(1:floor(NewSignal2Noise*obj.Settings.DotsN))= 1;
    end
    
    %% regenerating 
    function [obj]= Regenerate(obj)
      %% find "dead" dots
      iDeadSignal= find(obj.LifeLeft==0 & obj.ShouldBeSignal==1);
      iDeadNoise= find(obj.LifeLeft==0 & obj.ShouldBeSignal==0);
      iDead= [iDeadSignal; iDeadNoise];
      
      %% marking signal
      obj.IsSignal(iDeadSignal)= 1;
      obj.IsSignal(iDeadNoise)= 0;
      
      %% generating dots at random locations
      obj.Coords(iDead, :)= obj.GenerateCoordsWithinCylinder(numel(iDead));
      
      %% generating random offset in 3D for noise dots
      obj.xyzOffset(iDeadSignal, :)= zeros(numel(iDeadSignal), 3);
      obj.xyzOffset(iDeadNoise, :)= rand(numel(iDeadSignal), 3).*2-1;
      
      %% generating speed matrix for all the noise dots
      
      %% marking signal dots and creating a shift for them
      obj.Dir(iDeadSignal)= obj.SignalDirection;
      obj.Dir(iDeadNoise)= rand(numel(iDeadNoise), 1)*2-1;
      
      %% reincarneting
      obj.LifeLeft(iDead)= obj.LifetimeInFrames;
    end
    
    %% advancing
    function [obj]= Advance(obj, NewSignal2Noise)
      % setting new signal-2-noise, if available
      if (exist('NewSignal2Noise', 'var') && ~isempty(NewSignal2Noise))
        obj.SetSignal2Noise(NewSignal2Noise);
      end;
      
      % advancing dots
      FrameSpeed= obj.trueR'.*(cos(obj.trueA+obj.AngularVelocity)-cos(obj.trueA));
      obj.XYZ(:, 1)= obj.XYZ(:, 1)+FrameSpeed.*cos(obj.Dir);
      obj.XYZ(:, 2)= obj.XYZ(:, 2)+FrameSpeed.*sin(obj.Dir);
      for iDim= 1:2,
        obj.XYZ(obj.XYZ(:, iDim)<-1, iDim)= obj.XYZ(obj.XYZ(:, iDim)<-1, iDim)+2;
        obj.XYZ(obj.XYZ(:, iDim)>1, iDim)= obj.XYZ(obj.XYZ(:, iDim)>1, iDim)-2;
      end;
      
      % rotating
      obj.trueA= mod(obj.trueA+obj.AngularVelocity, 2*pi);
      
      % reducing life
      obj.LifeLeft= obj.LifeLeft-1;
      obj.Regenerate;
    end
    
    %% drawing current snapshot
    function Draw(obj, ptbWindow, CenterXY)
      %% preparing arrays
      H = [obj.XYZ(:,1)*obj.Settings.Width/2+CenterXY(1), obj.XYZ(:,2)*obj.Settings.Height/2+CenterXY(2), obj.XYZ(:,1)*obj.Settings.Width/2+CenterXY(1), obj.XYZ(:,2)*obj.Settings.Height/2+CenterXY(2)]+obj.DotSize(:, :);
      Screen('FillOval', ptbWindow, obj.DotRGB(:, :), H');
    end
    
    %% getting real coherence level
    function [RealCoherence]= GetRealCoherence(obj)
      RealCoherence= numel(find(obj.Dir==obj.SignalDirection))/obj.Settings.DotsN;
    end
    
    %% setting direction of motion
    function [obj]= SetSignalDirection(obj, NewDirection)
      obj.SignalDirection= NewDirection;
    end
    
    %% generating dots with UNIFORM distribution, but make sure they are all within vertical cylinder of radius=1
    function [XYZ]= GenerateCoordsWithinCylinder(obj, N)
      XYZ= rand(N, 3)*2-1;
      r= hypot(XYZ(:, 1), XYZ(:, 2));
      iOutside= find(r>1);
      while (~isempty(iOutside)),
        XYZ(iOutside, 1:2)= rand(numel(iOutside), 2)*2-1;
        r(iOutside)= hypot(XYZ(iOutside, 1), XYZ(iOutside, 2));
        iOutside= find(r>1);
      end;
    end
    
    %% preparing speed matrix for an individual group 
    function [SpeedMatrix]= PrepareGroupSpeed(obj, speedX_Hz, speedY_Hz, speedZ_Hz)
      %% converting speed from Hz to degrees/frame
      speedX= speedX_Hz.*2*pi/obj.ScreenMode.hz;
      speedY= speedY_Hz.*2*pi/obj.ScreenMode.hz;
      speedZ= speedZ_Hz.*2*pi/obj.ScreenMode.hz;
      
      %% preparing speed matrix
      sX =[1 0 0; 0 cos(speedX) -sin(speedX); 0 sin(speedX) cos(speedX)];
      sY =[cos(speedY) 0 sin(speedY); 0 1 0; -sin(speedY) 0 cos(speedY)];
      sZ =[cos(speedZ) -sin(speedZ) 0; sin(speedZ) cos(speedZ) 0; 0 0 1];
      SpeedMatrix= sX*sY*sZ;
    end;
    
  end
end
