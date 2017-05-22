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

% alternative colormap - lowbluehighred
load('~/colormaps/mylowbluehighred.mat')

% maximum number of records
maxrec = 523;
disp(strcat('Maximum number of records=',int2str(maxrec)))
disp('Did you change nrecords=maxrec in adxx_*.meta as well?')

% set number of days between snapshots/outputs (adxx or ADJ)
daysBetweenOutputs = 14.0;

% starting date as a 'date number' (number of days since counter start)
date0_num = datenum('1992-01-01 12:00:00');
disp(' ')
disp(strcat('Initial date set to: ',datestr(date0_num)))
disp(' ')

% flag for making animations (or not)
goMakeAnimations = 0;

% for m_map_gcmfaces plotting
myProj = 3.1; %- Southern Ocean
%myProj=4.12; %- North Atlantic (between 30-85N)
%myProj=4.22; %- Test for Yavor 
disp(' ')
disp(strcat('Plotting projection set to=',sprintf('%04.2f',myProj)))
disp(' ')

% longs and lats for drawing a box on the plots
disp('Will draw box on plots/animations at boxlons/boxlats')

% -- for scotia, I think
%boxlons = [-53.5 -53.5 -49.5 -49.5 -53.5];
%boxlats = [-55.0 -50.0 -50.0 -55.0 -55.0];

% -- for central pacific patch
boxlons = [-100 -90 -90 -100 -100];
boxlats = [-48 -48 -52 -52 -48];

% -- for eastern pacific patch
%boxlons = [-85 -75 -75 -85 -85];
%boxlats = [-52 -52 -55 -55 -52];

% -- Labrador Sea
%boxlons = [-55 -55 -49 -49 -55];
%boxlats = [ 55  60  60  55  55];

% -- blank, when you don't want a box
%boxlons = [];
%boxlats = [];

% set file locations -----------------

disp('-- Setting paths')

% set root directory and experiment directory

% -- forward case 
%rootdir = '/data/expose/ECCOv4_fwd/';
%expdir = 'run.20yr.diags/';

% -- labrador sea
%rootdir = '/data/expose/labrador/';
%expdir = 'run_ad.20yr.ulsw.ptr/';
%expdir = 'run_ad.20yr.dlsw.ptr/';
%expdir = 'run_ad.20yr.ulsw.heat/';
%expdir = 'run_ad.20yr.dlsw.heat/';
%maskName = 'ulsw_mask';

% -- acsis 
%rootdir = '/data/expose/acsis/';
%expdir = 'run_ad.20yr.subpolar.top1000/';
%expdir = 'run_ad.20yr.natl.top1000/';

% -- orchestra
%rootdir = '/data/expose/orchestra/';
%expdir = 'run_ad.20yr.scotia/';

% -- expose
rootdir = '/data/expose/expose_global/';
expdir = 'run_ad.20yr.cpac.salt/';
%expdir = 'run_ad.20yr.epac.salt/';

% -- test for yavor
%rootdir = '/data/expose/acsis/';
%expdir = 'yavor/';

% grid location
gloc = strcat(rootdir,'grid/');
if exist(gloc,'dir')
  disp(' ')
  disp(strcat('grid location: ',gloc))
  disp(' ')
else 
  error('Grid files not found, check gloc in initial_setup.m')
end

% raw data file location
floc = strcat(rootdir,'experiments/',expdir);
if exist(floc,'dir')
  disp(' ')
  disp(strcat('file location: ',floc))
  disp(' ')
else
  error('Experiment files not found, check initial_setup.m')
end

% plot location
ploc = strcat(rootdir,'plots/',expdir);                    
if exist(ploc,'dir')
  disp(' ')
  disp(strcat('plot location: ',ploc))
  disp(' ')
else
  mkdir(ploc);
  disp(' ')
  disp(strcat('plot directory created at: ',ploc))
  disp(' ')
end

% data out location
dloc = strcat(rootdir,'data_out/',expdir);
if exist(dloc,'dir')
  disp(' ')
  disp(strcat('data out location: ',dloc))
  disp(' ')
else
  disp(' ')
  mkdir(dloc);
  disp(strcat('data out directory created at: ',dloc))
  disp(' ')
end

% animation location
if goMakeAnimations==1
  aloc = strcat(rootdir,'animations/',expdir);
  if exist(aloc,'dir')
    disp(' ')
    disp(strcat('animation location: ',aloc))
    disp(' ')
  else
    mkdir(aloc)
    disp(' ')
    disp(strcat('animation directory created at: ',aloc))
    disp(' ')
  end
end

% stdev location
%sloc = strcat(rootdir,'stdevs_wseasons/');
sloc = strcat(rootdir,'stdevs_anoms/');
if exist(sloc,'dir')
  disp(' ')
  disp(strcat('standard deviations location: ',sloc))
  disp(' ')
else
  error('Standard deviation directory not found, check variable: sloc.')
end

% physical and geometric parameters
d2rad = pi/180;         % Earth's rotation rate (1/s) 
rho_0 = 1.027e3;        % Reference density (kg/m^3)
omega = 7.272e-5;       % Earth's rotation rate (1/s)
Cp = 4022.0;		% Heat capacity (J/kg K) 
g = 9.81;		% Gravitational acceleration (m/s^2)

% load gcmfaces grid
disp(' ')
disp('-- Loading grid')
disp(' ')
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
  disp(' ')
  warning('initial_setup: no its.txt file detected')
  disp(' ')
end

% its 'its_ad.txt' file exists, load it
if exist(strcat(floc,'its_ad.txt'), 'file')
  disp(' ')
  load(strcat(floc,'its_ad.txt'));
  disp(' ')
else
  disp(' ')
  warning('initial_setup: no its_ad.txt file detected')
  disp(' ')
end

% if a 'list of masks' exists, read it in
if exist('list_of_masks.txt','file')
  filename = 'list_of_masks.txt'; 
  [masks,delimiterOut]=importdata(filename,' ');
else
  disp(' ')
  warning('initial_setup: no list_of_masks.txt file detected')
  disp(' ')
end

% create figure for 2D plot (reuse axes)    
figure('color','w',...
       'visible','off',...
       'units','pixels',...
       'position',[217 138 950 744])

% create figure for 2D plot (reuse axes)    
%hf2 = figure('color','w',...
%             'visible','off',...
%             'units','pixels',...
%             'position',[217 138 950 744])

% current/default figure is hf1
%figure(hf1);

% load text file of adj fields and sigmas
filename = strcat(floc,'adj_list.txt');
if exist(filename,'file')
  [A,delimiterOut]=importdata(filename);
  B=regexp(A,delimiterOut,'split');
else
  error('initial_setup: adj_list.txt file not found \n')
end

% load fixed caxes, if they exist
filename = strcat(floc,'adj_cax.txt');
if exist(filename,'file')
  cax_fixed = 1;
  [C,delimiterOut]=importdata(filename);
  disp('adj_cax.txt file found, caxis limits will be fixed/constant')
else
  cax_fixed = 0;
  warning('No adj_cax.txt file found, caxis not fixed')
end


