% make_rawsens_plot: called by handle_adxx_files or handle_ADJ_files
% - this version (_rawsens_) just plots sensitivity fields (not dJ fields)
% - at present, plots vertical sum for 3D cases
% - plots dJfield (units of [J])
% - grabs a frame for the animation
% - can now fix color axis for all plots
%
% to be added:
% - for 3D fields, also plot a zonal mean (or maybe a cut) 

% default figure is hf1
%figure(hf1);

% save these files in 'raw' directory
plocNow = plocRaw;
zplocNow = zplocRaw;

% handle 2D and 3D cases
switch ndim

  case 2

    % select field to plot
    Fplot = adxx_now;
    nzlev = 0;

    % set color axis limits
    set_cax_raw_limits;

    % make plot
    m_map_gcmfaces(Fplot,myProj,...
                   {'myCmap',myCmap},...
                   {'myCaxis',myCax},...
                   {'doHold',1});

    % add contour showing region of interest
    if ~isempty(myMaskToPlot)
      m_map_gcmfaces({'contour',myMaskC,'k'},4.1,{'doHold',1});
    end

    % format and print
    format_and_print;

  case 3

    % calculate vertical sum for plot
    % DRF not needed for vertical sum! 
    % Sum has units of [J]
    Fplot = squeeze(nansum(adxx_now,3));
    nzlev = 0;

    % set color axis limits
    set_cax_raw_limits;

    % make plot
    m_map_gcmfaces(Fplot,myProj,...
                   {'myCmap',myCmap},...
                   {'myCaxis',myCax},...
                   {'doHold',1});

    % add contour showing region of interest
    if ~isempty(myMaskToPlot)
      m_map_gcmfaces({'contour',myMaskC,'k'},4.1,{'doHold',1});
    end

    % format and print
    format_and_print;

    % plot selected vertical levels
    for nzlev = 1:length(zlevs)

      % vertical level progress
      disp(strcat('---------- plotting vertical level=',int2str(nzlev)))

      % select the level
      Fplot = squeeze(adxx_now(:,:,zlevs(nzlev)));

      % set color axis limits
      set_cax_limits;

      % make the plot
      m_map_gcmfaces(Fplot,myProj,...
                    {'myCmap',myCmap},...
                    {'myCaxis',myCax},...
                    {'doHold',1});

      % add contour showing region of interest
      if ~isempty(myMaskToPlot)
        m_map_gcmfaces({'contour',myMaskC,'k'},4.1,{'doHold',1});
      end

      % format axes and labels, print as selected
      format_and_print;

    end

  otherwise

    error('make_a_plot: ndim must be 2 or 3')

end    

