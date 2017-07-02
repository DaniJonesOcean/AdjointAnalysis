%
% manual design of forward perturbation
%

%% initial setup

% clean up workspace
%clear all
%clear memory
%close all

% add paths 
addpath(genpath('/users/dannes/matlabfiles/'));
addpath(genpath('/users/dannes/gcmfaces/'));

% ------------ shouldn't have to change stuff below here ------

% set file locations
rootdir = '/data/expose/labrador/';
expdir = 'run_ad.20yr.labUpper.heat/';
floc = strcat(rootdir,'experiments/',expdir);
dloc = strcat(rootdir,'data_out/qnet_perturbations/',outset);
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

% get xx file full of zeros for formatting
xxExample = read_bin(strcat(floc,'xx_qnet.0000000012.data'));
xxExample(xxExample<Inf)=0.0;
xxZeros = xxExample;
maxrec = size(xxExample.f1,3);
ndays = 14.0*linspace(1,maxrec,maxrec);
xxOnes = xxExample;
xxOnes(xxOnes<Inf) = 1.0;

% get Labrador Sea mask
spatial_mask = read_bin('masks/lab_upper_maskC');
spatial_mask = repmat(spatial_mask,[1 1 maxrec]);

% date handling
date0_num = datenum('1992-01-01 12:00:00');
date_num = date0_num + ndays;
dates = datestr(date_num);
time_in_years = ndays./365.25;
lag_in_days = date_num - date_lag0;
lag_in_years = lag_in_days./365.25;

% temporal mask index values
justOnes = mygrid.XC;
justOnes(justOnes<Inf)=1.0;
justOnes = repmat(justOnes,[1 1 length(mskTindex)]);

% construct temporal mask (replace zeros with ones)
xxTimeMask = xxExample;
xxTimeMask(:,:,mskTindex) = justOnes;

% spatial mask
xxSpatialMask = spatial_mask;

% xx1 (the actual perturbations)
xx1 = xxOnes.*xxTimeMask.*xxSpatialMask.*perturbation_magnitude;

% write output
fOutName = strcat(dloc,'xx_qnet.0000000012.data');
write2file(fOutName,convert2gcmfaces(xx1));

% save description
save(strcat(dloc,'qnet_info.mat'))
