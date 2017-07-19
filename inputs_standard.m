%% Flags and parameters for analysis -----------------------------------

% debug mode flag (=0 debugging off, =1 debugging on)
debugMode = 0;

% state estimate iteration number (use with rdmds)
ad_iter = 12;

% manually set maximum number of records
maxrec = 28;

% theta, salt, or ptr?
myField = 'theta';

% set number of days between snapshots/outputs (adxx or ADJ)
% CAUTION: assumes that the days between adxx and ADJ outputs are the same
daysBetweenOutputs = 14.0;
%daysBetweenOutputs = 30.42;

% short analysis (1=just a few selected records) or long (0=all records)
doShortAnalysis = 1;

% gencost multiplier (check data.ecco to see what was used)
mult_gencost = 1.0e9;    % used for 2008 SO MXL heat content
%mult_gencost = 1.0;

% use single value for Fsig (as opposed to a spatially-varying std. dev.
useSingleFsigValue = 1;

% map container for single sigma values
keySet = {'THETA',...
          'SALT',...
          'EXFempmr',...
          'EXFqnet',...
          'EXFtaue',...
          'EXFtaun',...
          'NONE'};
valueSet = {0.3,...
            0.07,...
            2.0e-08,...
            60.0,...
            0.08,...
            0.06,...
            1.0};
FSigSingle = containers.Map(keySet,valueSet);

% apply sea ice mask: (1-f).*(field), where f=% SI cover
applySeaIceMask = 1;

% time scaling for ADJ fields 
% -- (duration of one ctrl period / duration of one timestep)
ADJ_time_scaling = 1209600/3600;

% starting date as a 'date number' (start of simulation)
date0_num = datenum('1992-01-01 12:00:00');

% date that is considered "lag zero"
%date_lag0 = datenum('1994-10-01 12:00:00');
%date_lag0 = datenum('2008-01-01 12:00:00');
date_lag0 = datenum('1992-01-01 12:00:00');

% list of adjoint sensitivity variables to load and process
myAdjList =   {'adxx_empmr',...
              'adxx_qnet',...
              'adxx_tauu',...
              'adxx_tauv'};
mySigmaList = {'EXFempmr',...
              'EXFqnet',...
              'EXFtaue',...
              'EXFtaun'};
          
    

% ----------------------------------------
%% --- set file locations -----------------
% ----------------------------------------

disp('-- Setting paths :::::::::: ')
disp('--')

% set root directory and experiment directory

% -- forward case (needed for mixed layer depth, sea ice)
%rootdir = '/data/expose/ECCOv4_fwd/';
%expdir = 'run.20yr.diags/';
fwdroot = '/data/expose/orchestra/';
fwddir = 'run.20yr.diags/';

% -- Southern Ocean mixed layer heat content
rootdir = '/data/oceans_output/open/emmomp/adjoint/';
%expdir = 'run_ad.20yr.SOmixlayer/';

% -- labrador sea
%rootdir = '/data/expose/labrador/';
%expdir = 'run_ad.20yr.labUpper.heat/';
%expdir = 'run_ad.20yr.labUpper.salt/';
%expdir = 'run_ad.20yr.labUpper.ptr/';
%expdir = 'run_ad.20yr.labMiddle.heat/';
%expdir = 'run_ad.20yr.labMiddle.ptr/';
%expdir = 'run_ad.20yr.labDeep.heat/';
%expdir = 'run_ad.20yr.labDeep.ptr/';

% use this for multiple experiments (all same units)
myExpList = {'run_ad.1yr.SOmixlayer/'};

% make sure directory names end with a '/' character
% switch myField
%     case 'salt'
%         myExpList = {'run_ad.20yr.labUpper.salt/',...
%                      'run_ad.20yr.labMiddle.salt/',...
%                      'run_ad.20yr.labDeep.salt/'};
%     case 'theta'
%         myExpList = {'run_ad.20yr.labUpper.heat/',...
%                      'run_ad.20yr.labMiddle.heat/',...
%                      'run_ad.20yr.labDeep.heat/'};        
%     case 'ptr'
%         myExpList = {'run_ad.20yr.labUpper.ptr/',...
%                      'run_ad.20yr.labMiddle.ptr/',...
%                      'run_ad.20yr.labDeep.ptr/'};        
%     otherwise
%         error('myField not set correctly.')
% end

%% Plotting parameters ----------------------------------------------------

% flag to either make 
% --- dJ plots ['dJ'], (dJ/dx)*\delta(x)
% --- raw sensitivity plots ['rawsens'] (dJ/dx)
% --- both (scaled dJ and raw sensitivity plots)
% --- neither ['none'], good for just calulating time series
%
%makePlots = 'dJ';
%makePlots = 'rawsens';
makePlots = 'both';
%makePlots = 'none';

% select mask to plot as contour
% -- set as empty [] for no contour
%myMaskToPlot = 'masks/lab_upper_maskC';
myMaskToPlot = [];

% flag for testing/exploration mode or production mode
myPlotMode = 'testing';
%myPlotMode = 'production';

switch myPlotMode
  case 'testing'
    whichColorBar = 'nl';
    myPlotFormat = 'jpg';
  case 'production'
    whichColorBar = 'cb2';
    myPlotFormat = 'eps';
  otherwise
    error('plotMode not set correctly')
end

% plot renderer (zbuffer, opengl (default), or painters)
%set(0, 'DefaultFigureRenderer', 'opengl');

% caxis scaling (only applies to automatically selected limits)
caxScale = 0.75;

% map container for nice titles (dJ maps)
degreeSymbol = sprintf('45%c', char(176));
keySet = {'THETA','SALT','QNET','EMPMR','TAUU','TAUV','PTRACER01'};
valueSet = {'dJ \theta [deg C]',...
            'dJ Salinity [deg C]',...
            'dJ Q_{net} [deg C]',...
            'dJ (E-p-r) [deg C]',...
            'dJ \tau_E [deg C]',...
            'dJ \tau_N [deg C]'...
            'dJ \phi [deg C]'};
niceTitle = containers.Map(keySet,valueSet);

% map container for nice titles (raw sensitivity fields)
keySet = {'THETA','SALT','QNET','EMPMR','TAUU','TAUV','PTRACER01'};
valueSet = {strcat('\d J / \d \theta [degC/degC]')...
            'dJ/dS [degC/psu]',...
            'dJ/dQ [degC/(W/m^2)]',...
            'dJ/d(E-p-r) [degC/(m/s)]',...
            'dJ/d(zonal wind stress) [degC/(N/m^2)]',...
            'dJ/d(merid. wind stress) [degC/(N/m^2)]',...
            'dJ/d(tracer) [degC/ptr]'};
%valueSet = {'dJ/dT [degrees C/degrees C]',...
%            'dJ/dS [degrees C/psu]',...                  
%            'dJ/dQ [degrees C/(W/m^2)]',...
%            'dJ/d(E-p-r) [degrees C/(m/s)]',...
%            'dJ/(zonal wind stress) [degrees C/(N/m^2)]',...
%            'dJ/(merid. wind stress) [degrees C/(N/m^2)]',...
%            'dJ/d(tracer) [degrees C/tracer]'};
niceTitleRaw = containers.Map(keySet,valueSet);

% use fixed colorbar axes (specified below, flag=1), or not (=0, default)
cax_fixed = 0;

% set to either plot MLD contours (=1) or not (=0, default)
plotMLD = 1;

% record numbers that you want to plot (select by index)
%myPlotRecs = [53 183 313 391];  
myPlotRecs = [1 13 26];  

% vertical levels that you want to plot (select by index)
plotZLEVS = 0;   % if =0, will only plot surface (no depths levels)
zlevs = [1 10 23 28 37 42];

% for m_map_gcmfaces plotting
%myProj = 0; %- all three
myProj = 1; %- Mercator only
%myProj = 3.1; %- Southern Ocean
%myProj=4.12; %- North Atlantic (between 30-85N)
%myProj=4.22; %- Test for Yavor 

% eiether make animations (=1) or not (=0)
goMakeAnimations = 0;
      
% -- select points for boxes to be put on plots

% -- for scotia sea      
%boxlons = [-53.5 -53.5 -49.5 -49.5 -53.5];
%boxlats = [-55.0 -50.0 -50.0 -55.0 -55.0];

% -- for central pacific patch
%boxlons = [-100 -90 -90 -100 -100];
%boxlats = [-48 -48 -52 -52 -48];

% -- for eastern pacific patch
%boxlons = [-85 -75 -75 -85 -85];
%boxlats = [-52 -52 -55 -55 -52];

% -- labrador sea
%boxlons = [-55 -55 -49 -49 -55];
%boxlats = [ 55  60  60  55  55];

% -- blank, when you don't want a box
boxlons = [];
boxlats = [];