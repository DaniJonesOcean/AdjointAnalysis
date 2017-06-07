% apply masks
%

% ---- read_bin or read2memory don't work ---
% bizarre error related to / operator...
% works fine as manual input, but not as a function?

for nmask=1:length(masks)

  % load mask
  maskname = masks{nmask};
  fld = read_bin(maskname);
% mask = convert2gcmfaces(fld);   % had to do this previously...
  mask = fld;                  

  % check dimensions (if not the same, skip it)
  if ndims(mask.f1)<ndim
 
   %warning('apply_masks.m: ndims(mask)~=ndim, skipping mask')
   warning('ndims(mask)<ndim, making some assumptions here (check)')
   %dJregional = [];

   % expand mask  
   mask=repmat(mask,[1 1 50]);
 
  end

  % apply mask to sensitivity fields and geometric factor
  adxx_now = adxx;
  adxx_now(~mask) = 0.0;
  geom_now = geom;
  geom_now(~mask) = NaN;

  % calculate dJregional.rn.mean and dJregional.rn.var
  calc_various_dJ_fields;

  % create regional using evalc (dJregional.r1.mean, dJregional.r2.mean, etc.)
  evalc(strcat('dJregional.justSum.r',int2str(nmask),...
               '.raw(',int2str(nrecord),') = dJraw_justSum_now;'));  
  evalc(strcat('dJregional.justSum.r',int2str(nmask),...
               '.mean(',int2str(nrecord),') = dJmean_justSum_now;'));
  evalc(strcat('dJregional.justSum.r',int2str(nmask),...
               '.var(',int2str(nrecord),') = dJvar_justSum_now;'));
% evalc(strcat('dJregional.xavg.r',int2str(nmask),...
%              '.raw(',int2str(nrecord),') = dJraw_now;'));  
% evalc(strcat('dJregional.xavg.r',int2str(nmask),...
%              '.mean(',int2str(nrecord),') = dJmean_now;'));
% evalc(strcat('dJregional.xavg.r',int2str(nmask),...
%              '.var(',int2str(nrecord),') = dJvar_now;'));

end

