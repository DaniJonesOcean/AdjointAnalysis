%makes 3D masks based on ECCO MLD depths. Specify time range and mean or
%max and name for output file

inputs
fwdloc = strcat(fwdroot,'experiments/',fwddir);
% if 'its.txt' file exists (list of iteration numbers), load it
if exist(strcat(fwdloc,'its.txt'), 'file')
    load(strcat(fwdloc,'its.txt'));
else
    disp('--')
    disp('-- initial_setup: no its.txt file detected')
    disp('--')
end

%years = {2007,2008};
%months = {12,[1,2]};
years = {1995};
months = {[1:12]};
areamask = 'south30S'; %choose area mask that exists in masks directory
masktype = 'mean'; % choose mean or max MLD
maskname = 'south30_mld95_mean';
gcmfaces_global;

% Calculate fwd run dates
dv = nan(length(its),6);
for t = 1:length(its)
    dv(t,:) = datevec(addtodate(datenum(1992,1,1),its(t),'hour'));
end

%Find your dates
idates = zeros(length(its),1);
for y = 1:length(years)
    for m = 1:length(months{y})
        idates = idates + (dv(:,1)==years{y} & dv(:,2)==months{y}(m));
    end
end

%Get model time steps
its_out = its(logical(idates));

%Load mixed layer
mld = get_mixlayerdepth(its_out',fwdroot,fwddir);

%Take time mean
mld_tmean = squeeze(nanmean(mld,3));

mld_SO = mld_tmean(mygrid.YC<=-30);

%Print stats
display('Mixed layer stats calculated for: ')
dv(logical(idates),1:2)
display('Max: ')
max(mld_SO)
display('Mean :')
nanmean(mld_SO)

%Load area mask
if exist(['masks/' areamask], 'file')
    areafld = read_bin(['masks/' areamask]);
else
    display('-- Area mask not found --')
end

%Make depth mask
depths = mygrid.RC;
maskfld = mld_tmean;
for iFace=1:mld_tmean.nFaces
        iF=num2str(iFace);
        eval(['fac = mld_tmean.f' iF ';'])
        eval(['amask = areafld.f' iF ';'])       
        mask = zeros([size(fac),length(depths)]);
        for x = 1:size(fac,1)
            for y = 1:size(fac,2)
                if amask(x,y) == 1
                    [~,mli] = min(abs(fac(x,y)+depths));
                    mask(x,y,1:mli)=1;
                end
            end
        end 
        
        eval(['maskfld.f' iF '=mask;'])
end

write2file(['masks/' maskname '_mask'],convert2gcmfaces(maskfld))
figure, m_map_gcmfaces(sum(maskfld,3))