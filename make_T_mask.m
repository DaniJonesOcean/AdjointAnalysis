function make_T_mask(startdate,nMonths,years,months,maskname)
% Writes T mask for adjoint runs 
% NB Assumes average period is 1 month
%startdate = datenum(1992,1,1); Start date of run
%nMonths = 4*12; Number of months in run
% Integral limits
%years = {1995,1996};  Years for mask
%months = {[1:12],[1:2]}; Months for mask (corresponding to years)
%maskname = 'south30_mld95_mean'; Name for mask

% Initialise mask
tMask = zeros(nMonths+10,1); % Padding required beyond end of fwd run

% Get dates of run
dv = nan(nMonths,6);
for t = 1:nMonths
    dv(t,:) = datevec(addtodate(startdate,t-1,'month'));
end

% Create mask
for y = 1:length(years)
    for m = months{y}
        tMask(dv(:,1)==years{y} & dv(:,2)==m)=1;
    end   
end

fid =fopen(['masks/' maskname '_maskT'],'w','b');
fwrite(fid,tMask,'float32');
fclose(fid);
display(['Mask written to masks/' maskname '_maskT'])

