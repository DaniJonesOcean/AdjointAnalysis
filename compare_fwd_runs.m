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
floc = '/data/expose/labrador/experiments/qnet_local_perturbations/';
gloc = '/data/expose/labrador/grid/';
dloc = '/data/expose/labrador/data_out/qnet_perturbations/qnet_1993_40Wm2_stats.mat';
varPositive = strcat(floc,'run.1993.pos40/diag_3D_set1');
varNegative = strcat(floc,'run.1993.neg40/diag_3D_set1');
varControl = strcat(floc,'run.20yr.diags/diag_3D_set2');

% load iterations
load(strcat(floc,'run.20yr.diags/its.txt'));

% load grid
warning('off')
gcmfaces_global;
grid_load(gloc,5,'compact',1);
warning('on')

% vertical grid
dz = mygrid.DRF;
dzz = dz';

% load spatial mask
mskC = read_bin('masks/lab_upper_maskC');
mskC = repmat(mskC,[1 1 50]);

% start with empty arrays
TpositiveBar = [];
TnegativeBar = [];
TcontrolBar = [];

% min/max iterations
%niterMin = locate(its,336) + 12;
%niterMax = niterMin + 3;
%niterMax = length(its) - 12;
niterMin = 1;
niterMax = length(its);

% loop through each iteration                               
for niter = niterMin:niterMax
%for niter = 1:length(its)

  % progress counter
  disp(100*(niter - niterMin)/(niterMax - niterMin));
% disp(100*niter/length(its));

  % progression
% ncount = niter - niterMin + 1;
  ncount = niter;

  % date handling
% ndays(ncount) = (its(niter)-its(niterMin))./24.0;
  ndays(ncount) = its(niter)./24.0;
  nyears(ncount) = ndays(ncount)./365.25;

  % load positive, negative, and control
  fPositive = rdmds2gcmfaces(varPositive,its(niter),'rec',1);
  fNegative = rdmds2gcmfaces(varNegative,its(niter),'rec',1);
  fControl = rdmds2gcmfaces(varControl,its(niter),'rec',1);

  % load 10 for average
% fPositiveBar = rdmds2gcmfaces(varPositive,...
%                                its(niter-12:niter+12)','rec',1);
% fPositiveBar = squeeze(nanmean(fPositiveBar,4));
% fNegativeBar = rdmds2gcmfaces(varNegative,...
%                                its(niter-12:niter+12)','rec',1);
% fNegativeBar = squeeze(nanmean(fNegativeBar,4));
% fControlBar = rdmds2gcmfaces(varControl,...
%                                its(niter-12:niter+12)','rec',1);
% fControlBar = squeeze(nanmean(fControlBar,4));

  % average heat content in each case
  [Tlab_pos,area] = calc_mskmean_T(fPositive,mskC);
  [Tlab_neg,area] = calc_mskmean_T(fNegative,mskC);
  [Tlab_control,area] = calc_mskmean_T(fControl,mskC);   

  % add to array
% TpositiveBar = cat(1,TpositiveBar,tmp1);
% TnegativeBar = cat(1,TnegativeBar,tmp2);
% TcontrolBar = cat(1,TcontrolBar,tmp3);

  % following Verdy et al. 2014 notation (replace h with y)
  % apply spatial mask (only want Lab Sea response)
  y1 = (Tlab_pos - Tlab_control);
  y2 = (Tlab_neg - Tlab_control);
  
  % form linear and non-linear terms of expansion
  Y1 = (y1 - y2)./2.0; Y1sq = Y1.^2;
  Y2 = (y1 + y2)./2.0; Y2sq = Y2.^2;

  % % vertical mean (upper)
  Y1rms_upper(ncount) = squeeze(nansum(Y1sq(1:27).*dzz(1:27)))./...
                squeeze(nansum(dzz(1:27))); 
  Y2rms_upper(ncount) = squeeze(nansum(Y2sq(1:27).*dzz(1:27)))./...
                squeeze(nansum(dzz(1:27)));
  % vertical mean (middle)
  Y1rms_middle(ncount) = squeeze(nansum(Y1sq(28:39).*dzz(28:39)))./...
                 squeeze(nansum(dzz(28:39))); 
  Y2rms_middle(ncount) = squeeze(nansum(Y2sq(28:39).*dzz(28:39)))./...
                 squeeze(nansum(dzz(28:39)));
  % vertical mean (deep)
  Y1rms_deep(ncount) = squeeze(nansum(Y1sq(40:44).*dzz(40:44)))./...
               squeeze(nansum(dzz(40:44))); 
  Y2rms_deep(ncount) = squeeze(nansum(Y2sq(40:44).*dzz(40:44)))./...
               squeeze(nansum(dzz(40:44)));
  % vertical mean (total)
  Y1rms_total(ncount) = squeeze(nansum(Y1sq(1:44).*dzz(1:44)))./...
               squeeze(nansum(dzz(1:44))); 
  Y2rms_total(ncount) = squeeze(nansum(Y2sq(1:44).*dzz(1:44)))./...
               squeeze(nansum(dzz(1:44)));

  % RMS (14-day mean temperature response)
% Y1rms(ncount) = sqrt(squeeze(nanmean(Y1sq(:))));
% Y2rms(ncount) = sqrt(squeeze(nanmean(Y2sq(:))));

  % following Verdy et al. 2014 notation (replace h with y)
  % apply spatial mask (only want Lab Sea response)
% y1Bar = (fPositiveBar - fControlBar).*mskC;
% y2Bar = (fNegativeBar - fControlBar).*mskC;
  
  % form linear and non-linear terms of expansion
% Y1Bar = (y1Bar - y2Bar)./2.0; Y1sqBar = Y1Bar.^2;
% Y2Bar = (y1Bar + y2Bar)./2.0; Y2sqBar = Y2Bar.^2;

  % RMS (annual mean temperature response)
% Y1rmsBar(ncount) = sqrt(squeeze(nanmean(Y1sqBar(:))));
% Y2rmsBar(ncount) = sqrt(squeeze(nanmean(Y2sqBar(:))));

end

% save results
save(dloc,'ncount',...
          'Y1rms_upper','Y2rms_upper',...
          'Y1rms_middle','Y2rms_middle',...
          'Y1rms_deep','Y2rms_deep',...
          'Y1rms_total','Y2rms_total',...
          'ndays','nyears','niterMin','niterMax','its',...
          'varPositive','varNegative','varControl','floc','gloc',...
          'TpositiveBar','TnegativeBar','TcontrolBar','area');
%save(dloc,'Y1rms','Y2rms','ncount',...
%          'ndays','nyears','niterMin','niterMax','its',...
%          'varPositive','varNegative','varControl','floc','gloc');
