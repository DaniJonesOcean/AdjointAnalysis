% calc_various_dJ_fields
% --- for summary statistics
% --- 
% --- Updates
% - Got rid of distinction between 'geo' and 'nogeo' 
% - All dJfields have units of [J] now.
% - The dJraw, dJmean, and dJvar series are area/volume averaged
% - 'justSum' is the numerator of area/volume average

% debugging message 
if debugMode==1
  disp('----------- calc_various_dJ_fields')
end

% if sigma exists, apply it. Otherwise, don't
if doesSigmaExist==1
  dJfield = adxx_now.*Fsig;
elseif doesSigmaExist==0
  dJfield = adxx_now;  % can be interpreted as perturbations of 1 unit 
else
  warning('calc_various_dJ_fields: doesSigmaExist not set properly')
end

%  scale dJfield for summation
%  (adxx/ADJ) = (length of ctrl period)/(length of one timestep)
%  adxx is already scaled appropriately; gives total impact
switch ad_name(1:3)
  case 'adx'
    ff = dJfield;   % adxx fields do not require spatiotemporal scaling
  case 'ADJ'
    ff = dJfield.*ADJ_time_scaling;  % temporal scaling only
    % spatial scaling (divide by dz)
    if (spatialScaling)&&(ndim==3)
      ff = ff./DRF3D;
      ampWeightedTime_num_now = ndays(nrecord).*abs(ff); 
      ampWeightedTime_den_now = abs(ff);
    end
  otherwise
    warning('Unexpected sensitivity field name')
end

% raw (no absolute value, just taken as-is)                          
dJraw_justSum_now = squeeze(nansum(ff(:)));

% mean (spatially uniform, basin scale) and spatially varying sens
dJmean_justSum_now = abs(squeeze(nansum(ff(:))));

% spatially varying sensitivities (area/volume mean)
dJvar_justSum_now = squeeze(nansum(abs(ff(:))));

% --- get rid of spatial averages, just work with sums

% raw (no absolute value, just taken as-is)                          
%dJraw_now = dJraw_justSum_now./squeeze(nansum(geom_now(:)));

% mean (spatially uniform, basin scale) and spatially varying sens
%dJmean_now = dJmean_justSum_now./squeeze(nansum(geom_now(:)));

% spatially varying sensitivities (area/volume mean)
%dJvar_now = dJvar_justSum_now./squeeze(nansum(geom_now(:)));

