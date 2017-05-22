% calc_various_dJ_fields
% --- for summary statistics
% --- 
% --- Updates
% - Got rid of distinction between 'geo' and 'nogeo' 
% - All dJfields have units of [J] now.
% - The dJraw, dJmean, and dJvar series are area/volume averaged
% - 'justSum' is the numerator of area/volume average

% if sigma exists, apply it. Otherwise, don't
if doesSigmaExist==1
  dJfield = adxx_now.*Fsig;
elseif doesSigmaExist==0
  dJfield = adxx_now;
else
  warning('calc_various_dJ_fields: doesSigmaExist not set properly')
end

% for summing
ff = dJfield.*geom_now;

% raw (no absolute value, just taken as-is)                          
dJraw_justSum_now = squeeze(nansum(ff(:)));

% mean (spatially uniform, basin scale) and spatially varying sens
dJmean_justSum_now = abs(squeeze(nansum(ff(:))));

% spatially varying sensitivities (area/volume mean)
dJvar_justSum_now = squeeze(nansum(abs(ff(:))));

% raw (no absolute value, just taken as-is)                          
dJraw_now = dJraw_justSum_now./squeeze(nansum(geom_now(:)));

% mean (spatially uniform, basin scale) and spatially varying sens
dJmean_now = dJmean_justSum_now./squeeze(nansum(geom_now(:)));

% spatially varying sensitivities (area/volume mean)
dJvar_now = dJvar_justSum_now./squeeze(nansum(geom_now(:)));

% END
