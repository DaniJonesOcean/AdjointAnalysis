%
% plot EXF variables (e.g. time series in some region)
% 

%% Initial setup

%clean up workspace
clear all
close all

% add paths (--IF NEW USER, CHANGE THESE TO YOUR PATHS--)
addpath /users/dannes/matlabfiles/
addpath /users/dannes/matlabfiles/m_map/
addpath /users/dannes/gcmfaces/

% locations
floc = '/data/expose/ECCOv4_fwd/experiments/run.20yr.diags/';
dloc = '/data/expose/ECCOv4_fwd/data_out/run.20yr.diags/';
gloc = '/data/expose/ECCOv4_fwd/grid/';

% iterations
load([floc 'its.txt']);

% grid
gcmfaces_global;
grid_load(gloc,5,'compact');

% list of masks
maskList = {'masks/in_labrador' ...
            'masks/in_irminger' ...
            'masks/in_nordic_seas' ...
            'masks/in_arctic' ...
            'masks/in_northern_north_atlantic' ...
            'masks/in_southern_north_atlantic'};

% masks
tmp1 = read_bin('masks/in_labrador');
tmp1(tmp1<Inf)=0.0;
myMasks = repmat(tmp1,[1 1 length(maskList)]);

% mask
for nmask=1:length(maskList)
  tmpMask = read_bin(maskList{nmask});
  myMasks(:,:,nmask) = tmpMask;
end

% list of EXF fields
fieldList1 = {'EXFhs   ' 'EXFhl   ' 'EXFlwnet' 'EXFswnet' 'EXFlwdn ' ...
              'EXFswdn ' 'EXFqnet ' 'EXFtaue ' 'EXFtaun ' 'EXFewind' ...
              'EXFnwind' 'EXFwspee'};
fieldList2 = {'EXFatemp' 'EXFaqh  ' 'EXFevap ' 'EXFpreci' 'EXFsnow ' ...
              'EXFempmr' 'EXFpress' 'EXFroff '};
fieldList = cat(2,fieldList1,fieldList2);

% declare
exfields = [];

% name
exfields.varnames = fieldList;
exfields.masknames = maskList;

% time0
date_num0 = datenum('1992-01-01 12:00:00');

% loop through all iterations
for niter=1:length(its)

  % display progress
  disp(100*niter/length(its))

  % times
  exfields.datenums(niter) = date_num0 + its(niter)./24;

  % load data for this iteration
  exf1 = rdmds2gcmfaces(strcat(floc,'diag_exf_set1'),its(niter));
  exf2 = rdmds2gcmfaces(strcat(floc,'diag_exf_set2'),its(niter));
  exf = cat(3,exf1,exf2);

  % rotate wind stress
  EXFtaux = squeeze(exf1(:,:,8)); EXFtauy = squeeze(exf1(:,:,9));
  [EXFtaue, EXFtaun] = calc_UEVNfromUXVY(EXFtaux,EXFtauy);

  % rotate wind speed
  EXFuwind = squeeze(exf1(:,:,10)); EXFvwind = squeeze(exf1(:,:,11));
  [EXFewind, EXFnwind] = calc_UEVNfromUXVY(EXFuwind,EXFvwind);

  % extract time series for each
  for nvar=1:length(fieldList)

    for nmask=1:length(maskList)

      tmpA = calc_mskmean_T(squeeze(exf(:,:,nvar)),squeeze(myMasks(:,:,nmask)));
      evalc(['exfields.region(' int2str(nmask) ').var(' int2str(nvar) ').value(' int2str(niter) ') = tmpA;' ]); 

    end

  end

end

% save results
save([dloc 'exf_tseries.mat'],'exfields','floc','dloc','gloc')
