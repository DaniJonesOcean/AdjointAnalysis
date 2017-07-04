%
% adjoint analysis driver for use with ECCOv4 and gcmfaces
% --- D. Jones (dannes@bas.ac.uk), June 2017 
%
% >>>> assumes a certain directory structure (see directory_structure.txt)
%

%% Initial setup -------------------------------------------------------

% clean up workspace
clear all 
clear memory
close all 

% add paths (--IF NEW USER, CHANGE THESE TO YOUR PATHS--)
%addpath /users/dannes/matlabfiles/
addpath /users/dannes/matlabfiles/m_map/
addpath /users/dannes/gcmfaces/

% color maps (diverging, sequential, and alternate)
load('div11_RdYlBu.txt')
cmp = div11_RdYlBu./256;
cmp = flipud(cmp);
cmp(6,:) = [1.0 1.0 1.0];
load('seq9_Blues.txt')  
cmpSeq = seq9_Blues./256;
load('mylowbluehighred.mat')  % alternative colormap

% physical and geometric parameters
d2rad = pi/180;         % Earth's rotation rate (1/s) 
rho_0 = 1.027e3;        % Reference density (kg/m^3)
omega = 7.272e-5;       % Earth's rotation rate (1/s)
Cp = 4022.0;            % Heat capacity (J/kg K) 
g = 9.81;               % Gravitational acceleration (m/s^2)

% load user inputs
inputs

if strcmp(makePlots,'none') && doShortAnalysis == 1
    display 'WARNING no outputs will be created'
    yn = input('Type 1 to continue: ');
    if yn~=1
        return
    end
end

% some text for the standard output
disp('--')
disp('-----------------------------------------------------------------')
disp('------ Sensitivity analysis - summary stats and plots -----------')
disp('-----------------------------------------------------------------')
disp('--')
disp('--')
disp(strcat('-- Maximum number of records=',int2str(maxrec)))
disp('--')
disp('------------>>> Did you change nrecords=maxrec in adxx_*.meta as well?')
disp('--')
disp(strcat('-- Initial date set to: ',datestr(date0_num)))
disp('--')
disp('--')
disp(strcat('-- Lag 0 date set to: ',datestr(date_lag0)))
disp('--')
disp('--')
disp(strcat('-- Plotting projection set to=',sprintf('%04.2f',myProj)))
disp('--')

% display animations selection
if goMakeAnimations==1          
  disp('--')
  disp('-- goMakeAnimations=1, animations will be created')
  disp('--')
else
  goMakeAnimations = 0;
  disp('--')
  disp('-- goMakeAnimations=0, animations will *not* be created')
  disp('--')
end

% use map containers to specify colorbar axis limits
switch myField
    case 'salt'
        containers_for_salt;
    case 'theta'
        containers_for_heat;
    case 'ptr'
        containers_for_ptr;
    otherwise
        error('myField option not recognised')
end


%% Sets paths, creates directories if needed, calls generic_stats

% ---------------------------------------------------------------------
% ---- You probably won't have to change anything below this line -----
% ---------------------------------------------------------------------

% possibly temporary - 'for' loop, multiple directories
for nExp=1:length(myExpList)

    % select experiment from list    
    expdir = myExpList{nExp};

    % set locations based on experiment selection ---------------
    
    % grid location
    gloc = strcat(rootdir,'grid/');
    if exist(gloc,'dir')
      disp('--')
      disp(strcat('-- grid location: ',gloc))
      disp('--')
    else 
      error('-- Grid files not found, check gloc in initial_setup.m')
    end

    % raw data file location
    floc = strcat(rootdir,'experiments/',expdir);
    if exist(floc,'dir')
      disp('--')
      disp(strcat('-- file location: ',floc))
      disp('--')
    else
      error('-- Experiment files not found, check initial_setup.m')
    end

    % plot location
    ploc = strcat(rootdir,'plots/',expdir,'dJ/');                    
    if exist(ploc,'dir')
      disp('--')
      disp(strcat('-- plot location: ',ploc))
      disp('--')
    else
      mkdir(ploc);
      disp('--')
      disp(strcat('-- plot directory created at: ',ploc))
      disp('--')
    end

    % separate folder for vertical levels
    zploc = strcat(ploc,'zlevs/');
    if exist(zploc,'dir')
      disp('--')
      disp('-- vertical level sub-folder found')
      disp('--')
    else
      mkdir(zploc)
      disp('--')
      disp('-- vertical level sub-folder created')
      disp('--')
    end

    % separate folder for raw sensitivity fields
    plocRaw = strcat(rootdir,'plots/',expdir,'rawSens/');                    
    if exist(plocRaw,'dir')
      disp('--')
      disp('-- folder for raw sensitivity plots found')
      disp('--')
    else
      mkdir(plocRaw)
      disp('--')
      disp('-- folder for raw sensitivity plots created')
      disp('--')
    end

    % separate folder for vertical levels
    zplocRaw = strcat(plocRaw,'zlevs/');
    if exist(zplocRaw,'dir')
      disp('--')
      disp('-- vertical level sub-folder found')
      disp('--')
    else
      mkdir(zplocRaw)
      disp('--')
      disp('-- vertical level sub-folder created')
      disp('--')
    end

    % data out location
    dloc = strcat(rootdir,'data_out/',expdir);
    if exist(dloc,'dir')
      disp('--')
      disp(strcat('-- data out location: ',dloc))
      disp('--')
    else
      disp('--')
      mkdir(dloc);
      disp(strcat('-- data out directory created at: ',dloc))
      disp('--')
    end

    % animation location
    if goMakeAnimations==1
      aloc = strcat(rootdir,'animations/',expdir);
      if exist(aloc,'dir')
        disp('--')
        disp(strcat('-- animation location: ',aloc))
        disp('--')
      else
        mkdir(aloc)
        disp('--')
        disp(strcat('-- animation directory created at: ',aloc))
        disp('--')
      end
    end

    % stdev location
    %sloc = strcat(rootdir,'stdevs_wseasons/');
    if ~useSingleFsigValue
        sloc = strcat(rootdir,'stdevs_anoms/');
        if exist(sloc,'dir')
            disp('--')
            disp(strcat('-- standard deviations location: ',sloc))
            disp('--')
        else
            error('-- std. dev. directory not found, check variable: sloc.')
        end
    end

    % load gcmfaces grid
    disp('--')
    disp('-- Loading gcmfaces grid')
    disp('--')
    warning('off') %#ok<*WNOFF>
    gcmfaces_global;
    % the '1' at the end is a memory limit - much faster performance
    grid_load(gloc,5,'compact',1);
    warning('on') %#ok<*WNON>

    % load mask for contour
    if ~isempty(myMaskToPlot) 
      myMaskC = read_bin(myMaskToPlot);
    end

    % area of grid cells
    DAC = mygrid.DXC.*mygrid.DYC.*mygrid.hFacC(:,:,1);

    % horizontal area of each cell
    DAC3D = repmat(DAC,[1 1 50]);
    DVC = DAC3D;
    DRF3D = DAC3D;

    % expand DRF to fit faces of DVC
    tmp = repmat(mygrid.DRF,[1 90 270]);
    tmp = permute(tmp,[2 3 1]);
    DVC.f1 = tmp.*(DAC3D.f1);
    DVC.f2 = tmp.*(DAC3D.f2);
    DRF3D.f1 = tmp;
    DRF3D.f2 = tmp;
    tmp = repmat(mygrid.DRF,[1 90 90]);
    tmp = permute(tmp,[2 3 1]);
    DVC.f3 = tmp.*(DAC3D.f3);
    DRF3D.f3 = tmp;
    tmp = repmat(mygrid.DRF,[1 270 90]);
    tmp = permute(tmp,[2 3 1]);
    DVC.f4 = tmp.*(DAC3D.f4);
    DVC.f5 = tmp.*(DAC3D.f5);
    DRF3D.f4 = tmp;
    DRF3D.f5 = tmp;
    DVC = DVC.*(mygrid.hFacC);
    total_volume = squeeze(nansum(DVC(:)));

    % if 'its.txt' file exists (list of iteration numbers), load it
    if exist(strcat(floc,'its.txt'), 'file')
      load(strcat(floc,'its.txt'));
    else
      disp('--')
      disp('-- initial_setup: no its.txt file detected')
      disp('--')
    end

    % its 'its_ad.txt' file exists, load it
    if exist(strcat(floc,'its_ad.txt'), 'file')
      disp('--')
      load(strcat(floc,'its_ad.txt'));
      disp('--')
    else
      disp('--')
      disp('-- initial_setup: no its_ad.txt file detected')
      disp('--')
    end

    % if a 'list of masks' exists, read it in
    if exist('list_of_masks.txt','file')
      filename = 'list_of_masks.txt'; 
      [masks,delimiterOut]=importdata(filename,' ');
    else
      disp('--')
      disp('-- initial_setup: no list_of_masks.txt file detected')
      disp('--')
    end

    % create figure for 2D plot (reuse these axes using 'cla' command)
    % if you don't use "cla" or equivalent, you may experience memory leakage    
    figure('color','w',...
           'visible','off',...
           'units','pixels',...
           'position',[217 138 950 744])

    % The rest of the analysis routines take it from here
    generic_stats

end
