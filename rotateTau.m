%
% rotate taux and tauy into taue and taun
%

% clean up workspace
clear all
close all

% add paths
addpath ~/matlabfiles/
addpath ~/gcmfaces/

% set file locations
myflocs = {...
           '/data/expose/orchestra/experiments/run_ad_orch_satl.heat/',...
          };
gloc = '/data/expose/labrador/grid/';

% load grid
gcmfaces_global;
grid_load(gloc,5,'compact');

% ad scaling
adt_scaling = 1.0;

for nexp=1:length(myflocs)

  % list of its
  load(strcat(myflocs{nexp},'its.txt'))

  for niter=1:length(its)
  
    % progress counter
    disp(strcat('---',' nexp=',int2str(nexp),' --- niter=',...
                int2str(niter),' of ',int2str(length(its))))

    % if exists, skip iteration
    fname_test = strcat(myflocs{nexp},'ADJtaue.',sprintf('%010d',its(niter)),'.meta');
    if exist(fname_test,'file')~=2

      % load taux and tauy
      taux = adt_scaling.*rdmds2gcmfaces(strcat(myflocs{nexp},...
                          'ADJtaux'),its(niter));
      tauy = adt_scaling.*rdmds2gcmfaces(strcat(myflocs{nexp},...
                          'ADJtauy'),its(niter));

      % rotate
      [taue,taun] = calc_UEVNfromUXVY(taux,tauy);

      % write out (taue)
      fname_dat = strcat(myflocs{nexp},'ADJtaue.',sprintf('%010d',its(niter)),'.data');
      fname_met = strcat(myflocs{nexp},'ADJtaue.',sprintf('%010d',its(niter)),'.meta');
      write2file(fname_dat,convert2gcmfaces(taue))
      mname = strcat(myflocs{nexp},'ADJtaux.',sprintf('%010d',its(niter)),'.meta');
      status = unix(['cp ',mname,' ',fname_met]);
      if status~=0
        warning('problem with copying meta file')
      end

      % write out (taun)
      fname_dat = strcat(myflocs{nexp},'ADJtaun.',sprintf('%010d',its(niter)),'.data');
      fname_met = strcat(myflocs{nexp},'ADJtaun.',sprintf('%010d',its(niter)),'.meta');
      write2file(fname_dat,convert2gcmfaces(taun))
      mname = strcat(myflocs{nexp},'ADJtauy.',sprintf('%010d',its(niter)),'.meta');
      status = unix(['cp ',mname,' ',fname_met]);
      if status~=0
         warning('problem with copying meta file')
      end

    else

      disp('-------- file aleady exists, skip it ----------')

    end    

  end

end
