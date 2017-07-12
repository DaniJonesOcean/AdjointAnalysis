%
% make some masks
%

%initial_setup
clear all
close all

% load grid
warning('off')
gcmfaces_global;
% the '1' at the end is a memory limit - let's see if it works
grid_load('/data/expose/ECCOv4_fwd/grid/',5,'compact',1);
warning('on')

% south of 30S
fld = v4_basin('atl');
fld(mygrid.YC>-30)=0.0;
fld(mygrid.YC<=-30)=1.0;
figure('color','w')
m_map_gcmfaces(fld)
title('South of 30S')
write2file('south30S',convert2gcmfaces(fld));
fld_south30S = fld;

% north of 30S
fld = v4_basin('atl');
fld(mygrid.YC>-30)=1.0;
fld(mygrid.YC<=-30)=0.0;
figure('color','w')
m_map_gcmfaces(fld)
title('North of 30S')
write2file('north30S',convert2gcmfaces(fld));
fld_north30S = fld;

% pac south 
fld_pac = v4_basin('pac');
fld = fld_pac & fld_south30S;
figure('color','w')
m_map_gcmfaces(fld)
title('pac Sector of SO')
write2file('south30S_pac',convert2gcmfaces(fld));
% pac north  
fld_pac = v4_basin('pac');
fld = fld_pac & fld_north30S;
figure('color','w')
m_map_gcmfaces(fld)
title('pac Sector')
write2file('north30S_pac',convert2gcmfaces(fld));

% atl south 
fld_atl = v4_basin('atl');
fld = fld_atl & fld_south30S;
figure('color','w')
m_map_gcmfaces(fld)
title('atl Sector of SO')
write2file('south30S_atl',convert2gcmfaces(fld));
% atl north  
fld_atl = v4_basin('atl');
fld = fld_atl & fld_north30S;
figure('color','w')
m_map_gcmfaces(fld)
title('atl Sector')
write2file('north30S_atl',convert2gcmfaces(fld));

% ind south 
fld_ind = v4_basin('ind');
fld = fld_ind & fld_south30S;
figure('color','w')
m_map_gcmfaces(fld)
title('ind Sector of SO')
write2file('south30S_ind',convert2gcmfaces(fld));
% ind north  
fld_ind = v4_basin('ind');
fld = fld_ind & fld_north30S;
figure('color','w')
m_map_gcmfaces(fld)
title('ind Sector')
write2file('north30S_ind',convert2gcmfaces(fld));


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


