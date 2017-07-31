%
% Extract lateral/depth Hovmollers of sensitivities using given masks
%

%% Initial setup --------------------------------------------

% clean up workspace
clear all
close all

% set paths
addpath /users/dannes/matlabfiles/
addpath /users/dannes/matlabfiles/m_map/
addpath /users/dannes/gcmfaces/

% set directories
rootdir = '/data/expose/labrador/';
gloc = strcat(rootdir,'grid/');
grid_special;

% date of start of simulation
date0_num = datenum('1992-01-01 12:00:00');

% list of experiments
myExpList = {'run_ad.20yr.labUpper.heat/'};

% date handling
myLagList = {datenum('1992-01-01 12:00:00')};

% list of masks
myMaskList = {'masks/in_labrador',...
              'masks/in_irminger',...
              'masks/in_nordic_seas',...
              'masks/in_northern_north_atlantic',...
              'masks/in_southern_north_atlantic',...
              'masks/in_arctic'};

%myExpList = {'run_ad.5yr.1996.labUpper.heat/' ...
%             'run_ad.5yr.1997.labUpper.heat/' ...
%             'run_ad.5yr.1998.labUpper.heat/' ...
%             'run_ad.5yr.1999.labUpper.heat/' ...
%             'run_ad.5yr.2000.labUpper.heat/' ...
%             'run_ad.5yr.2001.labUpper.heat/' ...
%             'run_ad.5yr.2002.labUpper.heat/' ...
%             'run_ad.5yr.2003.labUpper.heat/' ...
%             'run_ad.5yr.2004.labUpper.heat/' ...
%            'run_ad.5yr.2005.labUpper.heat/' ...
%            'run_ad.5yr.2006.labUpper.heat/' ...
%            'run_ad.5yr.2007.labUpper.heat/' ...
%            'run_ad.5yr.2008.labUpper.heat/' ...
%            'run_ad.5yr.2009.labUpper.heat/' ...
%            'run_ad.5yr.2010.labUpper.heat/' ...
%            'run_ad.5yr.2011.labUpper.heat/' ...
%           };

%myLagList = {datenum('1992-01-01 12:00:00') ...
%            datenum('1993-01-01 12:00:00') ...
%            datenum('1994-01-01 12:00:00') ...
%            datenum('1995-01-01 12:00:00') ...
%            datenum('1996-01-01 12:00:00') ...
%            datenum('1997-01-01 12:00:00') ...
%            datenum('1998-01-01 12:00:00') ...
%            datenum('1999-01-01 12:00:00') ...
%            datenum('2000-01-01 12:00:00') ...
%            datenum('2001-01-01 12:00:00') ...
%            datenum('2002-01-01 12:00:00') ...
%            datenum('2003-01-01 12:00:00') ...
%            datenum('2004-01-01 12:00:00') ...
%            datenum('2005-01-01 12:00:00') ...
%            datenum('2006-01-01 12:00:00') ...
%            datenum('2007-01-01 12:00:00') ...
%            datenum('2008-01-01 12:00:00') ...
%            datenum('2009-01-01 12:00:00') ...
%            datenum('2010-01-01 12:00:00') ...
%            datenum('2011-01-01 12:00:00')};

for nexp=1:length(myExpList) 

  expdir = myExpList{nexp};
  floc = strcat(rootdir,'experiments/',expdir);
  dloc = strcat(rootdir,'data_out/',expdir);
  load(strcat(floc,'its.txt'));
  lag0_num = myLagList{nexp};

  % start with empty arrays
  for nmask=1:length(myMaskList)

    evalc(strcat('ADJhovmol.region',int2str(nmask),'= [];'));

  end

  % loop through iterations
  for niter=1:length(its)

    % display progress
    disp('---')
    disp(expdir)
    disp(100*niter/length(its));
    disp('---')

    % date
    dateNow(niter) = date0_num + its(niter)/24;
    lag_in_days(niter) = dateNow(niter) - lag0_num;
    lag_in_years(niter) = lag_in_days(niter)/365.25;

    % load ADJ
    ADJnow = rdmds2gcmfaces(strcat(floc,'ADJtheta'),its(niter));

    % scale cells by depth
    ADJnow = ADJnow./DRF3D;  

    for nmask=1:length(myMaskList)

      msk = read_bin(myMaskList{nmask});

      % select subset / just get average as function of depth
      regionProfiles = gcmfaces_subset(msk,ADJnow,0);
      profMean = squeeze(nanmean(regionProfiles,1));  

      % hovmoller
      evalc(strcat('ADJhovmol.region',...
                   int2str(nmask),...
                   ' = cat(1,',...
                   'ADJhovmol.region',...
                   int2str(nmask),...
                   ',profMean);'));

    end

  end

  % 2D lag and depths
  niterMax = niter;
  lag2D = repmat(lag_in_years,[length(mygrid.RC) 1]);
  depth2D = repmat(mygrid.RC,[1 niterMax]);

  % grid stuff
  ADJhovmol.dateNow = dateNow;
  ADJhovmol.lag_in_years = lag_in_years;
  ADJhovmol.lag2D = lag2D;
  ADJhovmol.depth2D = depth2D;
  ADJhovmol.regionList = myMaskList;

  % save results
  save(strcat(dloc,'ADJ_lateralDepth_hovmol.mat'),'ADJhovmol');

end
