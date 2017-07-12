clear all
close all

addpath /users/dannes/matlabfiles/
addpath /users/dannes/matlabfiles/m_map/
addpath /users/dannes/gcmfaces/

gloc='/data/expose/ECCOv4_fwd/grid/';

warning('off') %#ok<*WNOFF>
gcmfaces_global;
% the '1' at the end is a memory limit - much faster performance
grid_load(gloc,5,'compact',1);
warning('on') %#ok<*WNON>

%% mask - Kerguelen shelf -----------------------------

msk = read_bin('petrel_ker_maskC');
write2file('in_ker',convert2gcmfaces(msk));
figure
m_map_gcmfaces(msk,1);
title('in ker')
mskNot = ~msk;
write2file('not_in_ker',convert2gcmfaces(mskNot));
figure
m_map_gcmfaces(mskNot,1);
title('not in ker')

msk(msk<Inf)=1.0;
msk(mygrid.XC>80)=0.0;
msk(mygrid.XC<60)=0.0;
msk(mygrid.YC<-55)=0.0;
msk(mygrid.YC>-45)=0.0;

figure
m_map_gcmfaces(msk,1)
title('in ker shelf')

write2file('in_kerg_shelf',convert2gcmfaces(msk));

%% mask - Campbell plateau -------------------------

msk = read_bin('petrel_ant_maskC');
write2file('in_ant',convert2gcmfaces(msk));
figure
m_map_gcmfaces(msk,1);
title('in ant')
mskNot = ~msk;
write2file('not_in_ant',convert2gcmfaces(mskNot));
figure
m_map_gcmfaces(mskNot,1);
title('not in ant')

msk(msk<Inf)=1.0;
xShifted = mygrid.XC;
isneg = xShifted<0.0;
xShifted = xShifted + 360.*isneg;
msk(xShifted<160)=0.0;
msk(xShifted>185)=0.0;
msk(mygrid.YC>-30)=0.0
msk(mygrid.YC<-55)=0.0;

figure
m_map_gcmfaces(msk,1)
title('in ant shelf')

write2file('in_campbell_shelf',convert2gcmfaces(msk))



