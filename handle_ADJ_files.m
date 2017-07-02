% handle_ADJ_files
% called by the main driver
%
% NOTE: assumes 1 hour timestep 
%

% THIS FILE IS NOT USED ANYMORE (handle_adxx_files can now handle both adxx and ADJ)

% MAY NOT BE NEEDED ANYMORE: using case statements, absorbed this into adxx_files....
%
%

% load sigma (variable called Fsig)
if doesSigmaExist
  load(strcat(sloc,sigma_name,'.mat'))
  disp(strcat('-------- loading sigma: ',sigma_name))
else
  disp('------')
  disp('-------- not loading sigma (not selected/found)')
  disp('------')
end

% d8
d8 = '-------- ';

% read sample file to get dimensions
sample = rdmds2gcmfaces(strcat(floc,ad_name),its_ad(1));
ndim = ndims(sample.f1);

% error check - Fsig must have same dimensions as sample
if (doesSigmaExist) && (ndims(Fsig.f1)~=ndim)
  error('-------- handle_ADJ_files: ndims(Fsig.f1) must equal ndims(ADJ.f1)')
end

% get geometric factor, depending on geometry
clear geom
switch ndim
  case 2
    geom = DAC;
  case 3
    geom = DVC;
  otherwise
    error('-------- handle_ADJ_files: ndims(ADJ.1) must be 2 or 3')
end

% report whether masks are being used or not
if exist('masks','var') && length(masks)>0
  disp(d8)
  disp('-------- masks file found, will generate regional stats') 
  disp(d8)
else
  disp(d8)
  disp('-------- no masks file found, global analysis only')
  disp(d8)
end

% create empty vectors to store various time series
dJglobal.justSum.raw = zeros(maxrec,1);
dJglobal.justSum.mean = zeros(maxrec,1);
dJglobal.justSum.var = zeros(maxrec,1);
%dJglobal.xavg.raw = zeros(maxrec,1);
%dJglobal.xavg.mean = zeros(maxrec,1);
%dJglobal.xavg.var = zeros(maxrec,1);

% cumulative maps
cumulative_map_raw = sample;
cumulative_map_raw(cumulative_map_raw<Inf)=0.0;
cumulative_map_mean = cumulative_map_raw;
cumulative_map_var = cumulative_map_mean;
nmaps = 0;

% perform either short (a few records) or long analysis (all records)
if doShortAnalysis==1
  % select specific records to load/plot
  recordVector = its_ad(myPlotRecs);
else
  % create vector for selecting/loading/plotting all records 
  recordVector = its_ad;
end

% load ADJ files
for nrecord=1:length(recordVector)

  % generic counter (no longer needed)
% ncount = nrecord;

  % display progress
  progress = 100.*nrecord/length(recordVector);
  disp(strcat(d8,' variable=',ad_name,' progress=',...
              sprintf('%3.2f',progress),' pct'))

  % number of days, date num
  ndays(nrecord) = recordVector(nrecord)/24;  % convert hours into days
  date_num(nrecord) = date0_num + ndays(nrecord);
  lag_in_days(nrecord) = date_num(nrecord) - date_lag0;
  lag_in_years(nrecord) = lag_in_days(nrecord)./365.25;

  % load adjoint sensitivity field
  adxx = rdmds2gcmfaces(strcat(floc,ad_name),recordVector(nrecord));

  % various dJs, scaled and unscaled (global case, no masks)
  % use adxx, don't modify the original/raw adxx
  adxx_now = adxx;
  geom_now = geom;

  if applySeaIceMask==1
    apply_seaice_mask;
  end

  % get mixed layer depth (produces mld_now) 
  get_mixlayerdepth;

  % calculate various DJ fields and cumulative maps
  calc_various_dJ_fields;
  calc_cumulative_maps;

  % create plots (or not)
  switch makePlots
    case 'dJ'
      isRaw = 0; make_a_plot;
    case 'rawsens'
      isRaw = 1; make_a_plot;
    case 'both'
      isRaw = 0; make_a_plot;
      isRaw = 1; make_a_plot;
    case 'none'
      quirk = [];
    otherwise
      warning('-------- makePlots flag not set properly, check initial_setup.m')
  end

  % various DJ sums
  dJglobal.justSum.raw(ncount) = dJraw_justSum_now;
  dJglobal.justSum.mean(ncount) = dJmean_justSum_now;
  dJglobal.justSum.var(ncount) = dJvar_justSum_now;
% dJglobal.xavg.raw(ncount) = dJraw_now;
% dJglobal.xavg.mean(ncount) = dJmean_now;
% dJglobal.xavg.var(ncount) = dJvar_now;

  % display for progress
  if debugMode==1
    disp(strcat('-------------- dJglobal.mean=',sprintf('%0.5g',dJglobal.justSum.mean(ncount))))
  end

  % if masks exist, apply them
  if exist('masks','var') && length(masks)>0
    apply_masks;
  else
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
disp(d8)
disp(strcat(d8,' saving results for:',ad_name));
save(strcat(dloc,'genstats_',ad_name,'.mat'),'dJglobal','dJregional',...
                 'ad_name','sigma_name','masks','ndays',...
                 'floc','ploc','dloc','sloc','gloc','nmaps',...
                 'cumulative_map_raw','cumulative_map_var','cumulative_map_mean',...
                 'date_num','dates','month','lag_in_days','lag_in_years');
disp(d8)
