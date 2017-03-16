%
% make some masks
%

%initial_setup

% scotia sea box
fld_scotia = v4_basin_one(3);
figure('color','w')
m_map_gcmfaces(fld_scotia)
title('Scotia Sea (box)')
write2file('scotia_mask',convert2gcmfaces(fld_scotia));

% everything but scotia
fld_not_scotia = fld_scotia;
fld_not_scotia(fld_scotia==1)=0;
fld_not_scotia(fld_scotia==0)=1;
figure('color','w')
m_map_gcmfaces(fld_not_scotia)
title('Everything except Scotia')
write2file('not_scotia_mask',convert2gcmfaces(fld_not_scotia));

% north atlantic one
fld_natl = read_bin('natl_mask');
figure('color','w')
m_map_gcmfaces(fld_natl)
title('North Atlantic')

% everything but North Atlantic
fld_not_natl = fld_natl;
fld_not_natl(fld_natl==1)=0;
fld_not_natl(fld_natl==0)=1;
figure('color','w')
m_map_gcmfaces(fld_not_natl)
title('Everything except NAtl')
write2file('not_natl_mask',convert2gcmfaces(fld_not_natl));

% everything but subpolar Natl
fld_subpolar = read_bin('subpolar_natl_mask');
fld_not_subpolar = fld_subpolar;
fld_not_subpolar(fld_subpolar==1)=0;
fld_not_subpolar(fld_subpolar==0)=1;
figure('color','w')
m_map_gcmfaces(fld_not_subpolar)
title('Everything except subpolar Natl')
write2file('not_subpolar_natl_mask',convert2gcmfaces(fld_not_subpolar));



% all atlantic
fld_atl = v4_basin('atl');
figure('color','w')
m_map_gcmfaces(fld_atl)
title('Atlantic')
write2file('atl_mask',convert2gcmfaces(fld_atl));

% all pacific  
fld_atl = v4_basin('pac');
figure('color','w')
m_map_gcmfaces(fld_atl)
title('Pacific')
write2file('pac_mask',convert2gcmfaces(fld_atl));

% all pacific  
fld_atl = v4_basin('ind');
figure('color','w')
m_map_gcmfaces(fld_atl)
title('Indian')
write2file('ind_mask',convert2gcmfaces(fld_atl));

% South Atlantic
fld_satl = fld_atl;
fld_satl(fld_natl>0) = 0.0; 
figure('color','w')
m_map_gcmfaces(fld_satl);
title('South Atlantic (and tropics)')
write2file('satl_mask',convert2gcmfaces(fld_satl));

% Arctic
fld_arctic = v4_basin('arct');
figure('color','w')
m_map_gcmfaces(fld_arctic);
title('Arctic')
write2file('arctic_mask',convert2gcmfaces(fld_arctic));

% gulf of mexico
fld_mexico = v4_basin('mexico');
figure('color','w')
m_map_gcmfaces(fld_mexico);
title('Gulf of Mexico')
write2file('mexico_mask',convert2gcmfaces(fld_mexico));

% Med sea
fld_med = v4_basin('med');
figure('color','w')
m_map_gcmfaces(fld_med);
title('Med')
write2file('med_mask',convert2gcmfaces(fld_med));

% North sea
fld_north = v4_basin('north');
figure('color','w')
m_map_gcmfaces(fld_north);
title('North Sea')
write2file('north_mask',convert2gcmfaces(fld_north));


