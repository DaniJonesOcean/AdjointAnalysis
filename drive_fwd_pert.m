%
% driver - creates a set of perturbation experiments in Qnet
%

%% 1 of 8 ------------------------------------------------

% clean up
clear all

% set name of perturbation experiment!
outset = 'qnet_jfm1993_pos10Wm2/';
perturbation_magnitude = 10.0;  % W/m^2
date_lag0 = datenum('1993-01-13 12:00:00');
mskTindex = 27:32;  % 13-Jan-1993 to 24-Mar-1993

% run generation script
design_fwd_perturb_manual
figure(1)
m_map_gcmfaces(xx1(:,:,27),4.1)
title(datestr(date_lag0))

%% 2 of 8 ------------------------------------------------

% clean up
clear all

% set name of perturbation experiment!
outset = 'qnet_jfm1993_pos40Wm2/';
perturbation_magnitude = 40.0;  % W/m^2
date_lag0 = datenum('1993-01-13 12:00:00');
mskTindex = 27:32;  % 13-Jan-1993 to 24-Mar-1993

% run generation script
design_fwd_perturb_manual
figure(2)
m_map_gcmfaces(xx1(:,:,27),4.1)
title(datestr(date_lag0))

%% 3 of 8 ------------------------------------------------

% clean up
clear all

% set name of perturbation experiment!
outset = 'qnet_jfm1993_neg10Wm2/';
perturbation_magnitude = -10.0;  % W/m^2
date_lag0 = datenum('1993-01-13 12:00:00');
mskTindex = 27:32;  % 13-Jan-1993 to 24-Mar-1993

% run generation script
design_fwd_perturb_manual
figure(3)
m_map_gcmfaces(xx1(:,:,27),4.1)
title(datestr(date_lag0))

%% 4 of 8 ------------------------------------------------

% clean up
clear all

% set name of perturbation experiment!
outset = 'qnet_jfm1993_neg40Wm2/';
perturbation_magnitude = -40.0;  % W/m^2
date_lag0 = datenum('1993-01-13 12:00:00');
mskTindex = 27:32;  % 13-Jan-1993 to 24-Mar-1993

% run generation script
design_fwd_perturb_manual
figure(4)
m_map_gcmfaces(xx1(:,:,27),4.1)
title(datestr(date_lag0))

%% 5 of 8 ------------------------------------------------

% clean up
clear all

% set name of perturbation experiment!
outset = 'qnet_jfm2003_pos10Wm2/';
perturbation_magnitude = 10.0;  % W/m^2
date_lag0 = datenum('2003-01-15 12:00:00');
mskTindex = 288:293;  % 15-Jan-2003 to 26-Mar-2003

% run generation script
design_fwd_perturb_manual
figure(5)
m_map_gcmfaces(xx1(:,:,288),4.1)
title(datestr(date_lag0))

%% 6 of 8 ------------------------------------------------

% clean up
clear all

% set name of perturbation experiment!
outset = 'qnet_jfm2003_pos40Wm2/';
perturbation_magnitude = 40.0;  % W/m^2
date_lag0 = datenum('2003-01-15 12:00:00');
mskTindex = 288:293;  % 15-Jan-2003 to 26-Mar-2003

% run generation script
design_fwd_perturb_manual
figure(6)
m_map_gcmfaces(xx1(:,:,288),4.1)
title(datestr(date_lag0))

%% 7 of 8 ------------------------------------------------

% clean up
clear all

% set name of perturbation experiment!
outset = 'qnet_jfm2003_neg10Wm2/';
perturbation_magnitude = -10.0;  % W/m^2
date_lag0 = datenum('2003-01-15 12:00:00');
mskTindex = 288:293;  % 15-Jan-2003 to 26-Mar-2003

% run generation script
design_fwd_perturb_manual
figure(7)
m_map_gcmfaces(xx1(:,:,288),4.1)
title(datestr(date_lag0))

%% 8 of 8 ------------------------------------------------

% clean up
clear all

% set name of perturbation experiment!
outset = 'qnet_jfm2003_neg40Wm2/';
perturbation_magnitude = -40.0;  % W/m^2
date_lag0 = datenum('2003-01-15 12:00:00');
mskTindex = 288:293;  % 15-Jan-2003 to 26-Mar-2003

% run generation script
design_fwd_perturb_manual
figure(8)
m_map_gcmfaces(xx1(:,:,288),4.1)
title(datestr(date_lag0))

