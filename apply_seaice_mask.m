%
% apply simple sea ice mask: 
%  reduce sensitivities by (1-f), where f is the sea ice fraction
%

% To use this, the time periods of the sea ice diagnostic output 
% must match the output periods of the adxx/ADJ files. There is *nothing* in 
% this script to make sure that condition is true, so it's up to you. 
%

% load sea ice concentration
if nrecord<=length(its_ad)

  % name for rdmds2gcmfaces call
  ficeloc = strcat(fwdroot,'experiments/',fwddir,'diag_2D_seaice1');

  % load sea ice area
  SIarea = rdmds2gcmfaces(ficeloc,its_ad(nrecord),'rec',1);
                     
  % apply sea ice mask
  switch ndim

    % 2D sensitivity field
    case 2

      % apply sea ice mask 
      adxx_noSImask = adxx_now;
      adxx_now = adxx_now.*(1-SIarea);

    % 3D sensitivity field (apply to top level only)
    case 3

      % apply sea ice mask to top level (face by face)
      adxx_now.f1(:,:,1) = adxx_now.f1(:,:,1).*(1-SIarea.f1);
      adxx_now.f2(:,:,1) = adxx_now.f2(:,:,1).*(1-SIarea.f2);
      adxx_now.f3(:,:,1) = adxx_now.f3(:,:,1).*(1-SIarea.f3);
      adxx_now.f4(:,:,1) = adxx_now.f4(:,:,1).*(1-SIarea.f4);
      adxx_now.f5(:,:,1) = adxx_now.f5(:,:,1).*(1-SIarea.f5);

  end

else

  warning('apply_seaice_mask.m :: nrecord>length(its_ad)')
  warning('SEA ICE MASK NOT APPLIED TO THIS RECORD')

end     
