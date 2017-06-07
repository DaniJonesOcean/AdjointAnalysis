% make_a_plot: called by handle_adxx_files or handle_ADJ_files
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
    nzlev = 0;    

    % set color axis limits
    set_cax_limits;

    % make plot
    m_map_gcmfaces(Fplot,myProj,{'myCmap',myCmap},{'myCaxis',myCax});
    format_and_print;

  case 3

    % calculate vertical sum for plot
    % DRF not needed for vertical sum! 
    % Sum has units of [J]
    Fplot = squeeze(nansum(dJfield,3));
    nzlev = 0;

    % set color axis limits
    set_cax_limits;

    % make plot
    m_map_gcmfaces(Fplot,myProj,{'myCmap',myCmap},{'myCaxis',myCax});
    format_and_print;

    % plot selected vertical levels
    for nzlev = 1:length(zlevs)

      % vertical level progress
      disp(strcat('--plotting vertical level=',int2str(nzlev)))

      % select the level
      Fplot = squeeze(dJfield(:,:,zlevs(nzlev)));

      % set color axis limits
      set_cax_limits;
 
      % make the plot
      m_map_gcmfaces(Fplot,myProj,{'myCmap',myCmap},{'myCaxis',myCax});
      format_and_print;

    end

  otherwise

    error('make_a_plot: ndim must be 2 or 3')

end    

