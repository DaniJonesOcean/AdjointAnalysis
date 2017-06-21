% set caxis limits and color map

% if ADJptracer, use sequential. Otherwise use diverging.
if strcmp(ad_name,'ADJptracer01')
  switch whichColorBar
    case 'nl'
      myCmap = mylowbluehighred(1:128,:);
    case 'cb2'
      myCmap = cmpSeq;
    otherwise
      myCmap = mylowbluehighred(1:128,:);
  end
  %myCmap = flipud(myCmap);
  isSequential = 1;
else
  switch whichColorBar
    case 'nl'
      myCmap = mylowbluehighred;
    case 'cb2'
      myCmap = cmp;
    otherwise
      myCmap = mylowbluehighred;
  end
  isSequential = 0;
end

% raw or not?
if nzlev==0
  if isRaw==1
    Cnow=myColorAxesRaw(ad_name);
  else
    Cnow=myColorAxes(ad_name);
  end
elseif nzlev>0
  if isRaw==1
    Cnow=myColorAxesRawZlev(ad_name);
  else
    Cnow=myColorAxesZlev(ad_name);
  end
else
  error('nzlev not set correctly')
end

% If caxis is fixed and plot is either sum or surface, used specified values. 
% nzlev==0 corresponds to either a column sum plot or just a surface plot
% Otherwise, calculate it.
if cax_fixed

  myCax(1) = Cnow(1);
  myCax(2) = Cnow(2);

else

  % use different scale depending on sequential/diverging
  if isSequential
    myCax(2) = caxScale.*max(Fplot(:));
    myCax(1) = 0.0;
  else
    myCax(2) = caxScale.*max(max(Fplot(:)),abs(min(Fplot(:))));
    myCax(1) = -1.0*myCax(2);
  end

end

% in case of NaNs
if max(isnan(myCax))==1
  myCax(2) = 1.0;
  myCax(1) = 0.0;
end


