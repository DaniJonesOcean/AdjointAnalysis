% calc_various_dJ_fields
% --- for summary statistics

% if sigma exists, apply it. Otherwise, don't
if doesSigmaExist==1
  dJfield = adxx_now.*geom_now.*Fsig;
  dJfield_nogeo = adxx_now.*Fsig;
elseif doesSigmaExist==0
  dJfield = adxx_now.*geom_now;
  dJfield_nogeo = adxx_now;
else
  warning('calc_various_dJ_fields: doesSigmaExist not set properly')
end

% raw (no absolute value, just taken as-is)                          
dJraw_justSum_now = squeeze(nansum(dJfield(:)));

% mean (spatially uniform, basin scale) and spatially varying sens
dJmean_justSum_now = abs(squeeze(nansum(dJfield(:))));

% spatially varying sensitivities (area/volume mean)
dJvar_justSum_now = squeeze(nansum(abs(dJfield(:))));

% raw (no absolute value, just taken as-is)                          
dJraw_now = dJraw_justSum_now./squeeze(nansum(geom_now(:)));

% mean (spatially uniform, basin scale) and spatially varying sens
dJmean_now = dJmean_justSum_now./squeeze(nansum(geom_now(:)));

% spatially varying sensitivities (area/volume mean)
dJvar_now = dJvar_justSum_now./squeeze(nansum(geom_now(:)));
