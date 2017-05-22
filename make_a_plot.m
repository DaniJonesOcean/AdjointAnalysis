% make_a_plot: called by handle_adxx_files or handle_ADJ_files
% - at present, plots vertical sum for 3D cases
% - plots dJfield (units of [J])
% - grabs a frame for the animation
% - can now fix color axis for all plots
%
% to be added:
% - for 3D fields, also plot a zonal mean (or maybe a cut) 

% default figure is hf1
%figure(hf1);

% handle 2D and 3D cases
switch ndim

  case 2

    % select field to plot
    Fplot = dJfield;
    
    % set color axis limits
    set_cax_limits;

    % make plot
    m_map_gcmfaces(Fplot,myProj,{'myCmap',myCmap},{'myCaxis',myCax});

  case 3

    % calculate vertical sum for plot
    % DRF not needed for vertical sum! 
    % Sum has units of [J]
    Fplot = squeeze(nansum(dJfield,3));

    % set color axis limits
    set_cax_limits;

    % make plot
    m_map_gcmfaces(Fplot,myProj,{'myCmap',myCmap},{'myCaxis',myCax});

    % make separate zonal plot
%   make_zonalmean_plot;

  otherwise

    error('make_a_plot: ndim must be 2 or 3')

end    

% name string formatting
tempS = ad_name;
tempR = strrep(tempS,'_',' ');

% box to indicate initial region
if ~isempty(boxlons)
  m_line(boxlons,boxlats,'color','k');
end

% title and date
title(strcat(strrep(ad_name,'_',' '),' :: ',...
             sprintf('%8.2f',ndays(ncount)./365),' years'));
m_text(0,-80,datestr(date_num(ncount),1))

% get frame, set paper position
orig_mode = get(gcf, 'PaperPositionMode');
set(gcf, 'PaperPositionMode', 'auto');
cdata = hardcopy(gcf, '-Dzbuffer', '-r0');
set(gcf, 'PaperPositionMode', orig_mode);
currFrame = im2frame(cdata);

% if flag is set, grab frame for animation
if goMakeAnimations==1
  writeVideo(vidObj,currFrame);
end

% print
print('-djpeg90',strcat(ploc,ad_name,'_',sprintf('%05d',ncount),'.jpg'));
print('-depsc2',strcat(ploc,ad_name,'_',sprintf('%05d',ncount),'.eps'));

% clear current figure window (attempt to stem memory leak)
cla;
