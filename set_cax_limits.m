% set caxis limits and color map

% if ADJptracer, use sequential. Otherwise use diverging.
if strcmp(ad_name,'ADJptracer01')
  myCmap = cmpSeq;
  isSequential = 1;
else
%  myCmap = cmp;
  myCmap = mylowbluehighred;
  isSequential = 0;
end

% if caxis is fixed, used that. Otherwise, calculate it
if cax_fixed

  myCax(1) = C(nvariable,1);
  myCax(2) = C(nvariable,2);

else

  % use different scale depending on sequential/diverging
  if isSequential
    myCax(2) = max(Fplot(:));
    myCax(1) = 0.0;
  else
    myCax(2) = max(max(Fplot(:)),abs(min(Fplot(:))));
    myCax(1) = -1.0*myCax(2);
  end

end

% in case of NaNs
if max(isnan(myCax))==1
  myCax(2) = 1.0;
  myCax(1) = 0.0;
end


