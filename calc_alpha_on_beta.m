%
% alpha/beta (for each output, to be averaged later)
%

%% Initial setup 

% clean up workspace
clear all
close all

% addpaths
addpath ~/matlabfiles/gsw/
addpath ~/matlabfiles/gsw/library/
addpath ~/matlabfiles/
addpath ~/gcmfaces/

% paths
floc = '/data/expose/ECCOv4_fwd/experiments/run.20yr.diags/';
gloc = '/data/expose/ECCOv4_fwd/grid/';

% load gcmfaces
gcmfaces_global;
grid_load(gloc,5,'compact');

% load iterations
load(strcat(floc,'its.txt'))

% pressure (hydrostatic)
fldP=0*mygrid.mskC; for kk=1:length(mygrid.RC); fldP(:,:,kk)=-mygrid.RC(kk); end;
msk=convert2vector(mygrid.mskC);
fldP=convert2vector(fldP);

% longitudes, latitudes
lon = repmat(mygrid.XC,[1 1 50]); fldLon = convert2vector(lon);
lat = repmat(mygrid.YC,[1 1 50]); fldLat = convert2vector(lat);

%% loop through each output, calculate alpha on beta

for niter=1:length(its)

  % display progress
  disp(100*niter/length(its))

  % load T,S
  T = rdmds2gcmfaces(strcat(floc,'diag_3D_set2'),its(niter),'rec',1);
  S = rdmds2gcmfaces(strcat(floc,'diag_3D_set2'),its(niter),'rec',2);
  fldT = convert2vector(T); fldS = convert2vector(S);

  % TEOS-10 approach
  disp('Entering TEOS-10 step')
  [fldSA,in_ocean] = gsw_SA_from_SP(fldS,fldP,fldLon,fldLat);
  fldCT = gsw_CT_from_pt(fldSA,fldT);
  alphaOnBeta = gsw_alpha_on_beta(fldSA,fldCT,fldP);
  fldAlphaOnBeta = convert2vector(alphaOnBeta);

  % write out (just binary data file)
  fname_dat = strcat(floc,'alphaOnBeta.',sprintf('%010d',its(niter)),'.data');
%  fname_met = strcat(floc,'alphaOnBeta.',sprintf('%010d',its(niter)),'.meta');
  write2file(fname_dat,convert2gcmfaces(fldAlphaOnBeta));
%  mname = strcat(floc,'T.',sprintf('%010d',its(niter)),'.meta');
%  status = unix(['cp ',mname,' ',fname_met]); 
%  if status~=0
%    warning('problem with copying meta file')
%  end

end
