%
% compare positive and negative perturbations to test non-linearity
%

%% Initial setup -------------------------------------------------------

% clean up workspace
clear all
clear memory
close all 

% add paths (--IF NEW USER, CHANGE THESE TO YOUR PATHS--)
addpath /users/dannes/matlabfiles/
addpath /users/dannes/matlabfiles/m_map/
addpath /users/dannes/gcmfaces/

% some constants
d2rad = pi/180;         % Earth's rotation rate (1/s) 
rho0 = 1.027e3;        % Reference density (kg/m^3)
omega = 7.272e-5;       % Earth's rotation rate (1/s)
Cp = 4022.0;            % Heat capacity (J/kg K) 
g = 9.81;               % Gravitational acceleration (m/s^2)

% select directories to compare
floc = '/data/expose/labrador/experiments/';
gloc = '/data/expose/labrador/grid/';
dloc = '/data/expose/labrador/data_out/perturb_test/perturb_stats.mat';
varPositive = strcat(floc,'run.20yr.lag5to4.5C.pos/diag_3D_set2');
varNegative = strcat(floc,'run.20yr.lag5to4.5C.neg/diag_3D_set2');
varControl = strcat(floc,'run.20yr.diags/diag_3D_set2');

% load iterations
load(strcat(floc,'run.20yr.diags/its.txt'));

% load grid
warning('off')
gcmfaces_global;
grid_load(gloc,5,'compact',1);
warning('on')

% load spatial mask
mskC = read_bin('masks/lab_upper_maskC');
mskC = repmat(mskC,[1 1 50]);

% start with empty arrays
TpositiveBar = [];
TnegativeBar = [];
TcontrolBar = [];

% min/max iterations
niterMin = locate(its,96768);
%niterMax = niterMin + 3;
niterMax = locate(its,144144) - 12;

% loop through each iteration                               
for niter = niterMin:niterMax
% for niter = 1:length(its)

  % progress counter
  disp(100*(niter - niterMin)/(niterMax - niterMin));

  % progression
  ncount = niter - niterMin + 1;

  % date handling
  ndays(ncount) = (its(niter)-its(niterMin))./24.0;
  nyears(ncount) = ndays(ncount)./365.25;

  % load positive, negative, and control
  fPositive = rdmds2gcmfaces(varPositive,its(niter),'rec',1);
  fNegative = rdmds2gcmfaces(varNegative,its(niter),'rec',1);
  fControl = rdmds2gcmfaces(varControl,its(niter),'rec',1);

  % load 10 for average
  fPositiveBar = rdmds2gcmfaces(varPositive,...
                                 its(niter-12:niter+12)','rec',1);
  fPositiveBar = squeeze(nanmean(fPositiveBar,4));
  fNegativeBar = rdmds2gcmfaces(varNegative,...
                                 its(niter-12:niter+12)','rec',1);
  fNegativeBar = squeeze(nanmean(fNegativeBar,4));
  fControlBar = rdmds2gcmfaces(varControl,...
                                 its(niter-12:niter+12)','rec',1);
  fControlBar = squeeze(nanmean(fControlBar,4));

  % average heat content in each case
  [tmp1,area] = calc_mskmean_T(fPositive,mskC);
  [tmp2,area] = calc_mskmean_T(fNegative,mskC);
  [tmp3,area] = calc_mskmean_T(fControl,mskC);   

  % add to array
  TpositiveBar = cat(1,TpositiveBar,tmp1);
  TnegativeBar = cat(1,TnegativeBar,tmp2);
  TcontrolBar = cat(1,TcontrolBar,tmp3);

  % following Verdy et al. 2014 notation (replace h with y)
  % apply spatial mask (only want Lab Sea response)
  y1 = (fPositive - fControl).*mskC;
  y2 = (fNegative - fControl).*mskC;
  
  % form linear and non-linear terms of expansion
  Y1 = (y1 - y2)./2.0; Y1sq = Y1.^2;
  Y2 = (y1 + y2)./2.0; Y2sq = Y2.^2;

  % RMS (14-day mean temperature response)
  Y1rms(ncount) = sqrt(squeeze(nanmean(Y1sq(:))));
  Y2rms(ncount) = sqrt(squeeze(nanmean(Y2sq(:))));

  % following Verdy et al. 2014 notation (replace h with y)
  % apply spatial mask (only want Lab Sea response)
  y1Bar = (fPositiveBar - fControlBar).*mskC;
  y2Bar = (fNegativeBar - fControlBar).*mskC;
  
  % form linear and non-linear terms of expansion
  Y1Bar = (y1Bar - y2Bar)./2.0; Y1sqBar = Y1Bar.^2;
  Y2Bar = (y1Bar + y2Bar)./2.0; Y2sqBar = Y2Bar.^2;

  % RMS (14-day mean temperature response)
  Y1rmsBar(ncount) = sqrt(squeeze(nanmean(Y1sqBar(:))));
  Y2rmsBar(ncount) = sqrt(squeeze(nanmean(Y2sqBar(:))));

end

% save results
save(dloc,'Y1rms','Y2rms','Y1rmsBar','Y2rmsBar','ncount',...
          'ndays','nyears','niterMin','niterMax','its',...
          'varPositive','varNegative','varControl','floc','gloc',...
          'TpositiveBar','TnegativeBar','TcontrolBar','area');
