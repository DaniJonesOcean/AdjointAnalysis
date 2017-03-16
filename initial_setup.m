%
% specially select some adjoint plots to scale
%

%% Initial setup ------------------------------------------

% clean up workspace
clear all 
clear memory
close all 

% display progress
disp('-------------------------------------------')
disp('Adjoint analysis - summary stats and plots')
disp('-------------------------------------------')

% add paths
addpath /users/dannes/matlabfiles/
addpath /users/dannes/matlabfiles/m_map/
addpath /users/dannes/gcmfaces/

% color maps (diverging and sequential)
load('~/colormaps/div11_RdYlBu.txt')
cmp = div11_RdYlBu./256;
cmp = flipud(cmp);
cmp(6,:) = [1.0 1.0 1.0];
load('~/colormaps/seq9_Blues.txt')  
cmpSeq = seq9_Blues./256;

% maximum number of records
maxrec = 522;
disp(strcat('Maximum number of records=',int2str(maxrec)))
disp('Did you change nrecords=maxrec in adxx_*.meta as well?')

% starting date as a 'date number' (number of days since counter start)
date0_num = datenum('1992-01-01 12:00:00');
disp(strcat('Initial date set to: ',datestr(date0_num)))

% for m_map_gcmfaces plotting
myProj = 3.1; %- Southern Ocean
%myProj=4.12; %- North Atlantic
%myProj=4.22; %- Test for Yavor 
disp(strcat('Plotting projection set to=',sprintf('%04.2f',myProj)))

% longs and lats for drawing a box on the plots
%disp('Will draw box on plots/animations at boxlons/boxlats')

% -- for scotia, I think
boxlons = [-53.5 -53.5 -49.5 -49.5 -53.5];
boxlats = [-55.0 -50.0 -50.0 -55.0 -55.0];

% -- for central pacific patch
%boxlons = [-100 -90 -90 -100 -100];
%boxlats = [-48 -48 -52 -52 -48];

% -- for eastern pacific patch
%boxlons = [-85 -75 -75 -85 -85];
%boxlats = [-52 -52 -55 -55 -52];

% -- blank, when you don't want a box
%boxlons = [];
%boxlats = [];

% set file locations -----------------

disp('-- Setting paths')

% set root directory and experiment directory

% -- acsis 
%rootdir = '/data/expose/acsis/';
%expdir = 'run_ad.20yr.subpolar.top1000/';
%expdir = 'run_ad.20yr.natl.top1000/';

% -- orchestra
rootdir = '/data/expose/orchestra/';
expdir = 'run_ad.20yr.scotia/';

% -- expose
%rootdir = '/data/expose/expose_global/';
%expdir = 'run_ad.20yr.cpac/';
%expdir = 'run_ad.20yr.epac/';

%rootdir = '/data/expose/acsis/';
%expdir = 'yavor/';

% grid location
gloc = strcat(rootdir,'grid/');
if exist(gloc,'dir')
  disp(strcat('grid location: ',gloc))
else 
  error('Grid files not found, check gloc in initial_setup.m')
end

% raw data file location
floc = strcat(rootdir,'experiments/',expdir);
if exist(floc,'dir')
  disp(strcat('file location: ',floc))
else
  error('Experiment files not found, check initial_setup.m')
end

% plot location
ploc = strcat(rootdir,'plots/',expdir);                    
if exist(ploc,'dir')
  disp(strcat('plot location: ',ploc))
else
  mkdir(ploc);
  disp(strcat('plot directory created at: ',ploc))
end

% data out location
dloc = strcat(rootdir,'data_out/',expdir);
if exist(dloc,'dir')
  disp(strcat('data out location: ',dloc))
else
  mkdir(dloc);
  disp(strcat('data out directory created at: ',dloc))
end

% animation location
aloc = strcat(rootdir,'animations/',expdir);
if exist(aloc,'dir')
  disp(strcat('animation location: ',aloc))
else
  mkdir(aloc)
  disp(strcat('animation directory created at: ',aloc))
end

% stdev location
sloc = strcat(rootdir,'stdevs_wseasons/');
if exist(sloc,'dir')
  disp(strcat('standard deviations location: ',sloc))
else
  error('Standard deviation directory not found.')
end

% physical and geometric parameters
d2rad = pi/180;         % Earth's rotation rate (1/s) 
rho_0 = 1.027e3;        % reference density, kg/m^3
omega = 7.272e-5;       % Earth's rotation rate, 1/s
g = 9.81;

% load gcmfaces grid
disp('-- Loading grid')
warning('off')
gcmfaces_global;
grid_load(gloc,5,'compact');
warning('on')

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
  warning('initial_setup: no its.txt file detected')
end

% its 'its_ad.txt' file exists, load it
if exist(strcat(floc,'its_ad.txt'), 'file')
  load(strcat(floc,'its_ad.txt'));
else
  warning('initial_setup: no its_ad.txt file detected')
end

% if a 'list of masks' exists, read it in
if exist('list_of_masks.txt','file')
  filename = 'list_of_masks.txt'; 
  [masks,delimiterOut]=importdata(filename,' ');
else
  warning('initial_setup: no list_of_masks.txt file detected')
end

% try creating single figure and reusing handles
figure('color','w',...
       'visible','off',...
       'units','pixels',...
       'position',[217 138 950 744])
