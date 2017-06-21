%
% adjoint analysis software for use with ECCOv4 and gcmfaces
% --- D. Jones (dannes@bas.ac.uk), June 2017 
%
% --- assumes a certain directory structure (see directory_structure.txt)
%

%% Initial setup -------------------------------------------------------

% clean up workspace
clear all 
clear memory
close all 

% header for standard output
disp('--')
disp('-----------------------------------------------------------------')
disp('------ Sensitivity analysis - summary stats and plots -----------')
disp('-----------------------------------------------------------------')
disp('--')

% add paths (--IF NEW USER, CHANGE THESE TO YOUR PATHS--)
addpath /users/dannes/matlabfiles/
addpath /users/dannes/matlabfiles/m_map/
addpath /users/dannes/gcmfaces/

% debug mode flag (=0 debugging off, =1 debugging on)
debugMode=0;

% state estimate iteration number (use with rdmds)
ad_iter = 12;

% manually set maximum number of records
maxrec = 523;
%maxrec = 48;
disp('--')
disp(strcat('-- Maximum number of records=',int2str(maxrec)))
disp('--')
disp('------------>>> Did you change nrecords=maxrec in adxx_*.meta as well?')

% set number of days between snapshots/outputs (adxx or ADJ)
% CAUTION: assumes that the days between adxx and ADJ outputs are the same
daysBetweenOutputs = 14.0;
%daysBetweenOutputs = 30.42;

% short analysis (1=just a few selected records) or long (0=all records)
doShortAnalysis = 0;

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

% apply sea ice mask: (1-f).*(field), where f=% SI cover
applySeaIceMask = 1;

% set to either plot MLD contours (=1) or not (=0, default)
plotMLD = 1;

% record numbers that you want to plot (select by index)
myPlotRecs = [53 183 313 391];  

% vertical levels that you want to plot (select by index)
plotZLEVS = 0;
zlevs = [1 10 23 28 37 42];

% eiether make animations (=1) or not (=0)
goMakeAnimations = 1;

% display animations selection
if goMakeAnimations==1          
  disp('--')
  disp('-- goMakeAnimations=1, animations will be created')
  disp('--')
else
  goMakeAnimations = 0;
  disp('--')
  disp('-- goMakeAnimations=0, animations will *not* be created')
  disp('--')
end

% list of adjoint sensitivity variables to load and process
myAdjList =   {'adxx_empmr',...
               'adxx_qnet',...
               'adxx_tauu',...
               'adxx_tauv'};
mySigmaList = {'EXFempmr',...
               'EXFqnet',...
               'EXFtaue',...
               'EXFtaun'};

% use fixed colorbar axes (specified below, flag=1), or not (=0, default)
cax_fixed = 1;

% use map containers to specify colorbar axis limits
%containers_for_salt;
containers_for_heat;
%containers_for_ptr;

% time scaling for ADJ fields 
% -- (duration of one ctrl period / duration of one timestep)
ADJ_time_scaling = 1209600/3600;

% starting date as a 'date number' (start of simulation)
date0_num = datenum('1992-01-01 12:00:00');
disp('--')
disp(strcat('-- Initial date set to: ',datestr(date0_num)))
disp('--')

% date that is considered "lag zero"
%date_lag0 = datenum('1994-10-01 12:00:00');
date_lag0 = datenum('2008-01-01 12:00:00');
disp('--')
disp(strcat('-- Lag 0 date set to: ',datestr(date_lag0)))
disp('--')

% for m_map_gcmfaces plotting
myProj = 3.1; %- Southern Ocean
%myProj=4.12; %- North Atlantic (between 30-85N)
%myProj=4.22; %- Test for Yavor 
disp('--')
disp(strcat('-- Plotting projection set to=',sprintf('%04.2f',myProj)))
disp('--')

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

% ----------------------------------------
% --- set file locations -----------------
% ----------------------------------------

disp('-- Setting paths :::::::::: ')
disp('--')

% set root directory and experiment directory

% -- forward case 
%rootdir = '/data/expose/ECCOv4_fwd/';
%expdir = 'run.20yr.diags/';
fwddir = 'run.20yr.diags/';

% -- Southern Ocean mixed layer heat content
rootdir = '/data/expose/orchestra/';
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
%expdir = 'run_ad.20yr.ulsw.ptr/';
%expdir = 'run_ad.20yr.dlsw.ptr/';
%expdir = 'run_ad.20yr.ulsw.heat/';
%expdir = 'run_ad.20yr.dlsw.heat/';
%maskName = 'ulsw_mask';

myExpList = {'run_ad.20yr.SOmixlayer/'};

% possibly temporary - 'for' loop, multiple directories
for nExp=1:length(myExpList)

expdir = myExpList{nExp};

% -- acsis 
%rootdir = '/data/expose/acsis/';
%expdir = 'run_ad.20yr.subpolar.top1000/';
%expdir = 'run_ad.20yr.natl.top1000/';

% -- orchestra
%rootdir = '/data/expose/orchestra/';
%expdir = 'run_ad.20yr.scotia/';

% -- expose
%rootdir = '/data/expose/expose_global/';
%expdir = 'run_ad.20yr.cpac.salt/';
%expdir = 'run_ad.20yr.epac.salt/';

% -- ICED
%rootdir = '/data/expose/iced/';
%expdir = 'run_ad.5yr.petrel.ant/';
%expdir = 'run_ad.5yr.petrel.ker/';

% -- test for yavor
%rootdir = '/data/expose/acsis/';
%expdir = 'yavor/';

%% -- color maps for plots and animations

% color maps (diverging and sequential)
load('~/colormaps/div11_RdYlBu.txt')
cmp = div11_RdYlBu./256;
cmp = flipud(cmp);
cmp(6,:) = [1.0 1.0 1.0];
load('~/colormaps/seq9_Blues.txt')  
cmpSeq = seq9_Blues./256;

% alternative colormap - lowbluehighred
load('~/colormaps/mylowbluehighred.mat')

%% ---------------------------------------------------------------------
%% ---- You probably won't have to change anything below this line -----
%% ---------------------------------------------------------------------

% flag for making animations (or not)
% to make animations, set doShortAnalysis=0 and 
% select either 'dJ' or 'rawsens'  
%if (doShortAnalysis==0) && ...
%     (strcmp(makePlots,'dJ')||strcmp(makePlots,'rawsens'))
%  goMakeAnimations = 1;
%  disp('--')
%  disp('-- goMakeAnimations=1, animations will be created')
%  disp('--')
%else
%  goMakeAnimations = 0;
%  disp('--')
%  disp('-- goMakeAnimations=0, animations will *not* be created')
%  disp('--')
%end

%% set locations based on experiment selection ---------------

% grid location
gloc = strcat(rootdir,'grid/');
if exist(gloc,'dir')
  disp('--')
  disp(strcat('-- grid location: ',gloc))
  disp('--')
else 
  error('-- Grid files not found, check gloc in initial_setup.m')
end

% raw data file location
floc = strcat(rootdir,'experiments/',expdir);
if exist(floc,'dir')
  disp('--')
  disp(strcat('-- file location: ',floc))
  disp('--')
else
  error('-- Experiment files not found, check initial_setup.m')
end

% plot location
ploc = strcat(rootdir,'plots/',expdir,'dJ/');                    
if exist(ploc,'dir')
  disp('--')
  disp(strcat('-- plot location: ',ploc))
  disp('--')
else
  mkdir(ploc);
  disp('--')
  disp(strcat('-- plot directory created at: ',ploc))
  disp('--')
end

% separate folder for vertical levels
zploc = strcat(ploc,'zlevs/');
if exist(zploc,'dir')
  disp('--')
  disp('-- vertical level sub-folder found')
  disp('--')
else
  mkdir(zploc)
  disp('--')
  disp('-- vertical level sub-folder created')
  disp('--')
end

% separate folder for raw sensitivity fields
plocRaw = strcat(rootdir,'plots/',expdir,'rawSens/');                    
if exist(plocRaw,'dir')
  disp('--')
  disp('-- folder for raw sensitivity plots found')
  disp('--')
else
  mkdir(plocRaw)
  disp('--')
  disp('-- folder for raw sensitivity plots created')
  disp('--')
end

% separate folder for vertical levels
zplocRaw = strcat(plocRaw,'zlevs/');
if exist(zplocRaw,'dir')
  disp('--')
  disp('-- vertical level sub-folder found')
  disp('--')
else
  mkdir(zplocRaw)
  disp('--')
  disp('-- vertical level sub-folder created')
  disp('--')
end

% data out location
dloc = strcat(rootdir,'data_out/',expdir);
if exist(dloc,'dir')
  disp('--')
  disp(strcat('-- data out location: ',dloc))
  disp('--')
else
  disp('--')
  mkdir(dloc);
  disp(strcat('-- data out directory created at: ',dloc))
  disp('--')
end

% animation location
if goMakeAnimations==1
  aloc = strcat(rootdir,'animations/',expdir);
  if exist(aloc,'dir')
    disp('--')
    disp(strcat('-- animation location: ',aloc))
    disp('--')
  else
    mkdir(aloc)
    disp('--')
    disp(strcat('-- animation directory created at: ',aloc))
    disp('--')
  end
end

% stdev location
%sloc = strcat(rootdir,'stdevs_wseasons/');
sloc = strcat(rootdir,'stdevs_anoms/');
if exist(sloc,'dir')
  disp('--')
  disp(strcat('-- standard deviations location: ',sloc))
  disp('--')
else
  error('-- standard deviation directory not found, check variable: sloc.')
end

% physical and geometric parameters
d2rad = pi/180;         % Earth's rotation rate (1/s) 
rho_0 = 1.027e3;        % Reference density (kg/m^3)
omega = 7.272e-5;       % Earth's rotation rate (1/s)
Cp = 4022.0;		% Heat capacity (J/kg K) 
g = 9.81;		% Gravitational acceleration (m/s^2)

% load gcmfaces grid
disp('--')
disp('-- Loading gcmfaces grid')
disp('--')
warning('off')
gcmfaces_global;
% the '1' at the end is a memory limit - much faster performance
grid_load(gloc,5,'compact',1);
warning('on')

% load mask for contour
if ~isempty(myMaskToPlot) 
  myMaskC = read_bin(myMaskToPlot);
end

% area of grid cells
DAC = mygrid.DXC.*mygrid.DYC.*mygrid.hFacC(:,:,1);

% horizontal area of each cell
DAC3D = repmat(DAC,[1 1 50]);
DVC = DAC3D;
DRF3D = DAC3D;

% expand DRF to fit faces of DVC
tmp = repmat(mygrid.DRF,[1 90 270]);
tmp = permute(tmp,[2 3 1]);
DVC.f1 = tmp.*(DAC3D.f1);
DVC.f2 = tmp.*(DAC3D.f2);
DRF3D.f1 = tmp;
DRF3D.f2 = tmp;
tmp = repmat(mygrid.DRF,[1 90 90]);
tmp = permute(tmp,[2 3 1]);
DVC.f3 = tmp.*(DAC3D.f3);
DRF3D.f3 = tmp;
tmp = repmat(mygrid.DRF,[1 270 90]);
tmp = permute(tmp,[2 3 1]);
DVC.f4 = tmp.*(DAC3D.f4);
DVC.f5 = tmp.*(DAC3D.f5);
DRF3D.f4 = tmp;
DRF3D.f5 = tmp;
DVC = DVC.*(mygrid.hFacC);
total_volume = squeeze(nansum(DVC(:)));

% if 'its.txt' file exists (list of iteration numbers), load it
if exist(strcat(floc,'its.txt'), 'file')
  load(strcat(floc,'its.txt'));
else
  disp('--')
  disp('-- initial_setup: no its.txt file detected')
  disp('--')
end

% its 'its_ad.txt' file exists, load it
if exist(strcat(floc,'its_ad.txt'), 'file')
  disp('--')
  load(strcat(floc,'its_ad.txt'));
  disp('--')
else
  disp('--')
  disp('-- initial_setup: no its_ad.txt file detected')
  disp('--')
end

% if a 'list of masks' exists, read it in
if exist('list_of_masks.txt','file')
  filename = 'list_of_masks.txt'; 
  [masks,delimiterOut]=importdata(filename,' ');
else
  disp('--')
  disp('-- initial_setup: no list_of_masks.txt file detected')
  disp('--')
end

% default is empty (attempt to fix an odd error)
dJregional = [];
masks = [];
% need to fix the above....

% create figure for 2D plot (reuse these axes using 'cla' command)
% if you don't use "cla" or equivalent, you may experience memory leakage    
figure('color','w',...
       'visible','off',...
       'units','pixels',...
       'position',[217 138 950 744])

% -- everything below this line is not needed anymore and can probably be ignored --

% create figure for 2D plot (reuse axes)    
%hf2 = figure('color','w',...
%             'visible','off',...
%             'units','pixels',...
%             'position',[217 138 950 744])

% current/default figure is hf1
%figure(hf1);

% load text file of adj fields and sigmas
%filename = strcat(floc,'adj_list.txt');
%if exist(filename,'file')
%  [A,delimiterOut]=importdata(filename);
%  B=regexp(A,delimiterOut,'split');
%else
%  error('-- initial_setup: adj_list.txt file not found')
%end

% load fixed caxes, if they exist
%filename = strcat(floc,'adj_cax.txt');
%if exist(filename,'file')
%  cax_fixed = 1;
%  [C,delimiterOut]=importdata(filename);
%  disp('--')
%  disp('-- adj_cax.txt file found, caxis limits will be fixed/constant')
%  disp('--')
%else
%  cax_fixed = 0;
%  warning('-- No adj_cax.txt file found, caxis not fixed')
%end

% load fixed caxes, if they exist
%filename = strcat(floc,'adj_cax_raw.txt');
%if exist(filename,'file')
%  cax_raw_fixed = 1;
%  [Craw,delimiterOut]=importdata(filename);
%  disp('--')
%  disp('-- adj_cax_raw.txt file found, caxis limits will be fixed/constant')
%  disp('--')
%else
%  cax_raw_fixed = 0;
%  disp('--')
%  warning('-- No adj_cax_raw.txt file found, caxis not fixed')
%  disp('--')
%end

%% Generic stats ----- the rest of the analysis routines take it from here
% summary statistics dJmean and dJvar 
generic_stats

end
