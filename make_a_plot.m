% make_a_plot: called by handle_adxx_files or handle_ADJ_files
% - plots dJfield (units of [J])
% - grabs a frame for the animation
% - can now fix color axis for all plots
%
% to be added:
% - for 3D fields, also plot a zonal mean (or maybe a cut) 

% default figure is hf1
%figure(hf1);

if isRaw
  plocNow = plocRaw; zplocNow = zplocRaw;
else
  plocNow = ploc; zplocNow = zploc; 
end

% handle 2D and 3D cases
switch ndim

  case 2

    % select field to plot
    if isRaw==1
      Fplot = adxx_now;
    else
      Fplot = dJfield;
    end

    % nzlev=0 is either a 2D plot or just surface
    nzlev = 0;    

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

    % mixed layer depth contours
    if (plotMLD)&&(~isempty(mld_now))
%     m_map_gcmfaces({'contour',mld_now,[250 5000],...
%                     'linewidth',1,'linestyle','-','color',[.6 0 0]},...
%                     myProj,{'doHold',1})
      m_map_gcmfaces({'contour',mld_now,[500 5000],...
                      'linewidth',1,'linestyle','--','color',[.6 0 0]},...
                      myProj,{'doHold',1})
    end

    % format axes and labels, print as selected
    format_and_print;

  case 3

    % calculate vertical sum for plot
    % DRF not needed for vertical sum! 
    % Sum has units of [J]
    if isRaw==1
      Fplot = squeeze(nansum(adxx_now,3));
    else
      Fplot = squeeze(nansum(dJfield,3));
    end
    nzlev = 0;

    % set color axis limits
    set_cax_limits;

    % make plot
    m_map_gcmfaces(Fplot,myProj,...
                  {'myCmap',myCmap},...
                  {'myCaxis',myCax},...
                  {'doHold',1});

    % add contour showing region of interest
    if ~isempty(myMaskToPlot)
      m_map_gcmfaces({'contour',myMaskC,'k'},4.1,{'doHold',1});
    end

    % mixed layer depth contours
    if (plotMLD)&&(~isempty(mld_now))
%     m_map_gcmfaces({'contour',mld_now,[250 5000],...
%                     'linewidth',1,'linestyle','-','color',[.6 0 0]},...
%                     myProj,{'doHold',1})
      m_map_gcmfaces({'contour',mld_now,[500 5000],...
                      'linewidth',1,'linestyle','--','color',[.6 0 0]},...
                      myProj,{'doHold',1})
    end

    % format axes and labels, print as selected
    format_and_print;

    % if plotZLEVS==1, plot selected vertical levels

    if plotZLEVS==1

      % plot selected vertical levels
      for nzlev = 1:length(zlevs)

        % vertical level progress
        disp(strcat('---------- plotting vertical level=',int2str(nzlev)))

        % select the level
        if isRaw==1
          Fplot = squeeze(adxx_now(:,:,zlevs(nzlev)));
        else
          Fplot = squeeze(dJfield(:,:,zlevs(nzlev)));
        end

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

        % mixed layer depth contours
        if (plotMLD)&&(~isempty(mld_now))
%         m_map_gcmfaces({'contour',mld_now,[250 5000],...
%                         'linewidth',1,'linestyle','-','color',[.6 0 0]},...
%                         myProj,{'doHold',1})
          m_map_gcmfaces({'contour',mld_now,[500 5000],...
                          'linewidth',1,'linestyle','--','color',[.6 0 0]},...
                          myProj,{'doHold',1})
        end

        % format axes and labels, print as selected
        format_and_print;

      end

    end

  otherwise

    error('make_a_plot: ndim must be 2 or 3')

end    

