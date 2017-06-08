% handle_adxx_files - script to read in adxx adjoint fields
% run by the main driver, which is called 'generic_stats.m'

% load sigma (variable called Fsig)
if doesSigmaExist
  load(strcat(sloc,sigma_name,'.mat'))
  disp(strcat('------ loading sigma: ',sigma_name))
else
  disp('------')
  disp('------ not loading sigma (not selected/found)')
  disp('------')
end

% read sample file to get dimensions
sample = rdmds2gcmfaces(strcat(floc,ad_name),12,'rec',1);
ndim = ndims(sample.f1);

% error check - Fsig must have same dimensions as sample
if doesSigmaExist && (ndims(Fsig.f1)~=ndim)
  error('------ handle_adxx_files: ndims(Fsig.f1) must equal ndims(adxx.f1)')
end

% get geometric factor, depending on geometry
clear geom
switch ndim
  case 2
    geom = DAC;
  case 3
    geom = DVC;
  otherwise
    disp('------')
    error('------ handle_adxx_files: ndims(adxx.1) must be 2 or 3')
    disp('------')
end

% if masks exist, apply them
if exist('masks','var') && length(masks)>0
  disp('------')
  disp('------ masks file found, will perform regional analysis')
  disp('------')
else
  disp('------')
  disp('------ no masks detected, only performing global analysis')
  disp('------')
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
  recordVector = myPlotRecs;
else
  % create vector for selecting/loading/plotting all records 
  recordVector = linspace(1,maxrec,maxrec);
end

% dash
d8 = '-------- ';

% load adjoint sensitivity fields, scale them
for nrecord=1:length(recordVector)

  % generic counter 
  ncount = recordVector(nrecord);

  % display progress
  progress = 100.*recordVector(nrecord)/maxrec;
  disp(strcat(d8,' variable=',ad_name,' progress=',...
              sprintf('%3.2f',progress),' pct'))

  % number of days, date num
  ndays(ncount) = daysBetweenOutputs*ncount;
  date_num(ncount) = date0_num + ndays(ncount);
  lag_in_days(ncount) = date_num(ncount) - date_lag0; 
  lag_in_years(ncount) = lag_in_days(ncount)./365.25;  

  % load adjoint sensitivity field
  adxx = rdmds2gcmfaces(strcat(floc,ad_name),12,'rec',recordVector(nrecord));

  % various dJs, scaled and unscaled (global case, no masks)
  % use adxx, don't modify the original/raw adxx
  adxx_now = adxx;
  geom_now = geom;

  % if selected, apply sea ice mask
  if (applySeaIceMask==1) 
    apply_seaice_mask;
  end

  % calc dJ fields and cumulative maps
  calc_various_dJ_fields;
  calc_cumulative_maps;

  % create plots (or not)
  switch makePlots
    case 'dJ'
      make_a_plot;
    case 'rawsens'
      make_rawsens_plot;
    case 'both'
      make_a_plot;
      make_rawsens_plot;
    case 'none'
      continue;
    otherwise
      warning('-------- makePlots flag not set properly, check initial_setup.m')
  end

  % add entires to dJ statistics vectors
  dJglobal.justSum.raw(ncount) = dJraw_justSum_now;
  dJglobal.justSum.mean(ncount) = dJmean_justSum_now;
  dJglobal.justSum.var(ncount) = dJvar_justSum_now;
% dJglobal.xavg.raw(ncount) = dJraw_now;
% dJglobal.xavg.mean(ncount) = dJmean_now;
% dJglobal.xavg.var(ncount) = dJvar_now;

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
if doShortAnalysis==1
  disp(d8)
  disp(strcat(d8,' short analysis done for:',ad_name));
  disp(strcat(d8,' results will *not* be saved'));
  disp(d8)
else
  disp(d8)
  disp(strcat(d8,' savings results for:',ad_name));
  save(strcat(dloc,'genstats_',ad_name,'.mat'),'dJglobal','dJregional',...
                   'ad_name','sigma_name','masks','ndays',...
                   'floc','ploc','dloc','sloc','gloc','nmaps',...
                   'cumulative_map_raw','cumulative_map_var','cumulative_map_mean',...
                   'dates','date_num','month','lag_in_days','lag_in_years');
  disp(d8)
end
