% handle_ADJ_files
% called by the main driver

% load sigma (variable called Fsig)
if doesSigmaExist
  load(strcat(sloc,sigma_name,'.mat'))
  disp(strcat('loading sigma: ',sigma_name))
else
  disp('-- Not loading sigma (not selected/found)')
end

% read sample file to get dimensions
sample = rdmds2gcmfaces(strcat(floc,ad_name),its_ad(1));
ndim = ndims(sample.f1);

% error check - Fsig must have same dimensions as sample
if (doesSigmaExist) && (ndims(Fsig.f1)~=ndim)
  error('handle_ADJ_files: ndims(Fsig.f1) must equal ndims(ADJ.f1)')
end

% get geometric factor, depending on geometry
clear geom
switch ndim
  case 2
    geom = DAC;
  case 3
    geom = DVC;
  otherwise
    error('handle_ADJ_files: ndims(ADJ.1) must be 2 or 3')
end

% create empty vectors to store various time series
dJglobal.justSum.raw = zeros(maxrec,1);
dJglobal.justSum.mean = zeros(maxrec,1);
dJglobal.justSum.var = zeros(maxrec,1);
dJglobal.xavg.raw = zeros(maxrec,1);
dJglobal.xavg.mean = zeros(maxrec,1);
dJglobal.xavg.var = zeros(maxrec,1);

% cumulative maps
cumulative_map_raw = sample;
cumulative_map_raw(cumulative_map_raw<Inf)=0.0;
cumulative_map_mean = cumulative_map_raw;
cumulative_map_var = cumulative_map_mean;
nmaps = 0;

% load ADJ files
for niter=1:length(its_ad)

  % generic counter
  ncount = niter;

  % display progress
  progress = 100.*niter/length(its_ad);
  disp(strcat('var=',ad_name,' prog=',sprintf('%3.2f',progress),' pct'))

  % number of days, date num
  ndays(ncount) = its_ad(niter)/24;
  date_num(ncount) = date0_num + ndays(ncount);

  % load adjoint sensitivity field
  adxx = rdmds2gcmfaces(strcat(floc,ad_name),its_ad(niter));

  % various dJs, scaled and unscaled (global case, no masks)
  % use adxx, don't modify the original/raw adxx
  adxx_now = adxx;
  geom_now = geom;
  calc_various_dJ_fields;
  calc_cumulative_maps;
  make_a_plot;
  dJglobal.justSum.raw(ncount) = dJraw_justSum_now;
  dJglobal.justSum.mean(ncount) = dJmean_justSum_now;
  dJglobal.justSum.var(ncount) = dJvar_justSum_now;
  dJglobal.xavg.raw(ncount) = dJraw_now;
  dJglobal.xavg.mean(ncount) = dJmean_now;
  dJglobal.xavg.var(ncount) = dJvar_now;

  % if masks exist, apply them
  if exist('masks','var') && length(masks)>0
    apply_masks;
  else
    disp('no masks detected, only performing global analysis')
    dJregional = [];
    masks = [];
  end

end

% cumulative maps
cumulative_map_raw = cumulative_map_raw./nmaps;
cumulative_map_var = cumulative_map_var./nmaps;
cumulative_map_mean = abs(cumulative_map_raw);

% date handling
dates = datestr(date_num);
month = dates(:,4:6);
monthconv;

% save results
disp(strcat('savings results for:',ad_name));
save(strcat(dloc,'genstats_',ad_name,'.mat'),'dJglobal','dJregional',...
                 'ad_name','sigma_name','masks','ndays',...
                 'floc','ploc','dloc','sloc','gloc',...
                 'cumulative_map_raw','cumulative_map_var','cumulative_map_mean',...
                 'date_num','dates','month');

