%
% design forward perturbation experiment using adxx files
%
% -- perturbations based on sensitivity fields

%% initial setup

% clean up workspace
clear all 
clear memory
close all 

% add paths 
addpath(genpath('/users/dannes/matlabfiles/'));
addpath(genpath('/users/dannes/gcmfaces/'));

% state estimate iteration number (use with rdmds)
ad_iter = 12;

% list of adjoint fields
myAdjList =   {'empmr',...
               'qnet',...
               'tauu',...
               'tauv'};

% chosen standard deviations (mean over North Atlantic)
mySigList = {2.0e-8,60.0,0.08,0.06};
FsigSingle = containers.Map(myAdjList,mySigList);

% select desired total impact on cost function
dJtarget = 10.0;

% set file locations
rootdir = '/data/expose/labrador/';
expdir = 'run_ad.20yr.labUpper.heat/';
outset = 'lag_5to4_5C/';
floc = strcat(rootdir,'experiments/',expdir);
dloc = strcat(rootdir,'data_out/',expdir,outset);
gloc = strcat(rootdir,'grid/');

% if dloc doesn't exist, make it
if ~exist(dloc,'dir')
  mkdir(dloc);
end

% grid load
warning('off')
gcmfaces_global;
grid_load(gloc,5,'compact',1);
warning('on')

% get example xx (all zeros)
xxExample = read_bin(strcat(floc,'xx_tauu.0000000012.data'));
xxExample(xxExample<Inf)=0.0;
maxrec = size(xxExample.f1,3);
ndays = 14.0*linspace(1,maxrec,maxrec);
xxOnes = xxExample;
xxOnes(xxOnes<Inf) = 1.0;

% region mask
spatial_mask = read_bin('masks/natl_mask');
spatial_mask = repmat(spatial_mask,[1 1 maxrec]);

% date handling
date0_num = datenum('1992-01-01 12:00:00');
date_lag0 = datenum('2008-01-01 12:00:00');
date_num = date0_num + ndays;
dates = datestr(date_num);
time_in_years = ndays./365.25;
lag_in_days = date_num - date_lag0;
lag_in_years = lag_in_days./365.25;

% temporal mask index values
mskTindex = 287:313;  % lag -5 to lag -4
justOnes = mygrid.XC;
justOnes(justOnes<Inf)=1.0;
justOnes = repmat(justOnes,[1 1 length(mskTindex)]);

% construct temporal mask (replace zeros with ones)
xxTimeMask = xxExample;
xxTimeMask(:,:,mskTindex) = justOnes; 

% temporal and spatial mask combined
bathymask = repmat(mygrid.hFacC(:,:,25),[1 1 maxrec]);
tsMask = xxOnes.*xxTimeMask.*spatial_mask.*bathymask;

% number of non-zero entries for total scaling purposes
myScalingFactor = myNNZ(tsMask,mygrid);

% for each variable to be perturbed
for nvar=1:length(myAdjList)

  % get name, standard deviation
  ad_name = myAdjList{nvar};
  mySig1 = FsigSingle(ad_name);

  % file out name
  fOutName = strcat(dloc,'xx_',myAdjList{nvar},'.0000000012.data');

  % get original xx file (full of zeros)
  xx0 = read_bin(strcat(floc,'xx_',myAdjList{nvar},'.0000000012.data'));

  % get adxx file (which contains sensitivity fields)
  adxx0 = read_bin(strcat(floc,'adxx_',myAdjList{nvar},'.0000000012.data'));

  % find locations with very low sensitivities (to be discarded)
  xx1_test = dJtarget.*(adxx0.^(-1)).*tsMask./myScalingFactor;
  adxx1 = adxx0;
  adxx1(abs(xx1_test)>2.0.*mySig1) = Inf;
 
  % actual perturbations 
  xx1 = dJtarget.*(adxx1.^(-1)).*tsMask./myScalingFactor;
  xx1(isnan(xx1)) = 0.0;

  % write sum of impacts
  dJ = adxx1.*xx1;
  dJtest = nansum(dJ(:));

  % apply negative of perturbation
  %xx1 = -1.0.*xx1;

  % display
  disp(strcat('ad_name=',ad_name))
  disp('dJ total')
  disp(dJtest)

  % write out perturbation
  write2file(fOutName,convert2gcmfaces(xx1));

end


