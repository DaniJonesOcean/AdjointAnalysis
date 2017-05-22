%
% make hindcast of target quantity
%

% this code is currently disconnected from nearly everything else...

% forward iterations
load('/data/expose/ECCOv4_fwd/experiments/run.20yr.diags/its.txt');
fwdfloc = '/data/expose/ECCOv4_fwd/experiments/run.20yr.diags/';

% display
disp('Series for hindcast')

% for each iteration, load theta and calculate heat content
for niter=1:length(its)

  % display progress
  disp(100*niter/length(its))

  % load theta
  theta = rdmds2gcmfaces(strcat(fwdfloc,'diag_3D_set2'),...
                         its(niter),'rec',1);

  % avg for this time period
  heatContent(niter) = rho_0.*Cp.*squeeze(nansum(theta.*myMask.*DVC));

end

% save results
save(strcat(dloc,'heatContent.mat'),'heatContent','floc','dloc','fwdfloc')
