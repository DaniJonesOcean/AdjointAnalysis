%
% get mixed layer depth for this record
%

% To use this, the time periods of the sea ice diagnostic output 
% must match the output periods of the adxx/ADJ files. There is *nothing* in 
% this script to make sure that condition is true, so it's up to you. 
%

% load sea ice concentration
if nrecord<=length(its_ad)

  % name for rdmds2gcmfaces call
  mld_location = strcat(fwdroot,'experiments/',fwddir,'diag_2D_set1');

  % load sea ice area
  mld_now = rdmds2gcmfaces(mld_location,its_ad(nrecord),'rec',1);

else

  warning('---------- get_mixlayerdepth.m :: nrecord>length(its_ad)')
  warning('---------- mixed layer not loaded here')
  mld_now = [];

end     
