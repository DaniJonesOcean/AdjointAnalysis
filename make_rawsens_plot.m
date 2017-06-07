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

% handle 2D and 3D cases
switch ndim

  case 2

    % select field to plot
    Fplot = adxx_now;

    % log10 magnitude (but keep signs)
%   Fplot.f1 = sign(Fplot.f1).*log10(abs(Fplot.f1));
%   Fplot.f2 = sign(Fplot.f2).*log10(abs(Fplot.f2));
%   Fplot.f3 = sign(Fplot.f3).*log10(abs(Fplot.f3));
%   Fplot.f4 = sign(Fplot.f4).*log10(abs(Fplot.f4));
%   Fplot.f5 = sign(Fplot.f5).*log10(abs(Fplot.f5));
    
    % set color axis limits
    set_cax_raw_limits;

    % make plot
    m_map_gcmfaces(Fplot,myProj,{'myCmap',myCmap},{'myCaxis',myCax});

  case 3

    % calculate vertical sum for plot
    % DRF not needed for vertical sum! 
    % Sum has units of [J]
    Fplot = squeeze(nansum(adxx_now,3));

    % log10 magnitude (but keep signs)
%   Fplot.f1 = sign(Fplot.f1).*log10(abs(Fplot.f1));
%   Fplot.f2 = sign(Fplot.f2).*log10(abs(Fplot.f2));
%   Fplot.f3 = sign(Fplot.f3).*log10(abs(Fplot.f3));
%   Fplot.f4 = sign(Fplot.f4).*log10(abs(Fplot.f4));
%   Fplot.f5 = sign(Fplot.f5).*log10(abs(Fplot.f5));

    % set color axis limits
    set_cax_raw_limits;

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
switch ad_name(1:3)
  case 'adx'
    ht=title(strcat(upper(ad_name(6:end)),' lag=',...
                 sprintf('%6.1f',lag_in_years(ncount)),' years'));
    m_text(0,48,datestr(date_num(ncount),1),'fontsize',16)
  case 'ADJ'
    ht=title(strcat(upper(ad_name(4:end)),' lag=',...
                 sprintf('%6.1f',lag_in_years(ncount)),' years'));
    m_text(0,48,datestr(date_num(ncount),1))
end

% title
set(ht,'FontSize',18)
set(gca,'FontSize',16)

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
print('-djpeg90',strcat(ploc,'justSens_',ad_name,'_',sprintf('%05d',ncount),'.jpg'));
%print('-depsc2',strcat(ploc,'justSens_',ad_name,'_',sprintf('%05d',ncount),'.eps'));

% clear current figure window (attempt to stem memory leak)
cla;
