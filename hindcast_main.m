%
% make hindcast of target quantity
%

%% Initial setup

initial_setup

%% Get masks all sorted out                

% read in 2D mask and vertical mask
mskC = read_bin(strcat(floc,maskName,'C'));
mskC3D = repmat(mskC,[1 1 50]);
fid = fopen(strcat(floc,maskName,'K'),'r','ieee-be');
mskZ = fread(fid,'float32');
fclose(fid);
fid = fopen(strcat(floc,maskName,'T'),'r','ieee-be');
mskT = fread(fid,'float32');
fclose(fid);

% make 3D mask
myMask = DVC;
myMask(myMask<Inf)=1.0;
tmp = repmat(mskZ,[1 90 270]);
tmp = permute(tmp,[2 3 1]);
myMask.f1 = tmp.*(mskC3D.f1);
myMask.f2 = tmp.*(mskC3D.f2);
tmp = repmat(mskZ,[1 90 90]);
tmp = permute(tmp,[2 3 1]);
myMask.f3 = tmp.*(mskC3D.f3);
tmp = repmat(mskZ,[1 270 90]);
tmp = permute(tmp,[2 3 1]);
myMask.f4 = tmp.*(mskC3D.f4);
myMask.f5 = tmp.*(mskC3D.f5);

%% hindcast fwd timeseries

hindcast_fwd_series;

%% construct hindcast from adjoint variables

% load text file of adj fields and sigmas
filename = strcat(floc,'adj_list.txt');
if exist(filename,'file')
  [A,delimiterOut]=importdata(filename);
  B=regexp(A,delimiterOut,'split');
else
  error('generic_stats: adj_list.txt file not found')
end

% for each adxx/ADJ and sigma pair, load in data
for nvariable=1:length(B)

  % isolate sensitivity field and sigma field name
  ad_name = strrep(B{nvariable}{1},' ','');

end

% NO TIME TO FINISH THIS. What next? 
