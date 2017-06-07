%
% calculate mean barotropic streamfunction from 20-year run
%

%% initial setup
initial_setup

%% path for velocity data
uvloc = strcat(rootdir,'experiments/',fwddir,'diag_3D_set1');

%% get iterations for 2008
load(strcat(rootdir,'experiments/',fwddir,'its2008.txt'));

%% load uvel, vvel
uvel = rdmds2gcmfaces(uvloc,its2008','rec',1);
vvel = rdmds2gcmfaces(uvloc,its2008','rec',2);

%% mean values
ubar = squeeze(nanmean(uvel,4));
vbar = squeeze(nanmean(vvel,4));

%% calculate barotropic streamfunction
psi = calc_barostream(ubar,vbar);

%% plot
m_map_gcmfaces(psi,4.1)

%% save
save(strcat(rootdir,'experiments/',fwddir,'baro2008.mat'),...
     'psi','its2008')

