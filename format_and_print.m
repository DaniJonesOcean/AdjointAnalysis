%
% formatting and printing functions, formerly housed in 'make_a_plot'
% 

% name string formatting
tempS = ad_name;
tempR = strrep(tempS,'_',' ');

% box to indicate initial region
if ~isempty(boxlons)
  m_line(boxlons,boxlats,'color','k');
end

switch ad_name(1:3)
  case 'adx'
    if isRaw==1
      t1=niceTitleRaw(upper(ad_name(6:end)));
    else
      t1=niceTitle(upper(ad_name(6:end)));
    end
    ht=title(strcat(t1,', lag=',...
                 sprintf('%6.1f',lag_in_years(nrecord)),' years'));
    m_text(65,65,datestr(date_num(nrecord),1),'fontsize',16)
  case 'ADJ'
    if isRaw==1
      t1=niceTitleRaw(upper(ad_name(4:end)));
    else
      t1=niceTitle(upper(ad_name(4:end)));
    end
    if nzlev==0
      ht=title(strcat(t1,', lag=',...
                      sprintf('%6.1f',lag_in_years(ncount)),' years'));
      m_text(65,65,datestr(date_num(ncount),1),'fontsize',16)
    elseif nzlev>0
      ht=title(strcat(t1,', lag=',...
                      sprintf('%6.1f',lag_in_years(ncount)),' years, ',...
                      'z=',sprintf('%4.0f',mygrid.RC(zlevs(nzlev))),' m'));
      m_text(65,65,datestr(date_num(ncount),1),'fontsize',16)
    end
end

% title
set(ht,'FontSize',16)
set(gca,'FontSize',16)

% if goMakeAnimations flag is set, then grab frame for animation
% must be column sum or a surface plot (i.e. nzlev==0)
if (goMakeAnimations==1)&&(nzlev==0)
  orig_mode = get(gcf, 'PaperPositionMode');
  set(gcf, 'PaperPositionMode', 'auto');
  cdata = hardcopy(gcf, '-Dzbuffer', '-r0');
  set(gcf, 'PaperPositionMode', orig_mode);
  currFrame = im2frame(cdata);
  writeVideo(vidObj,currFrame);
end

% title
set(ht,'FontSize',16)
set(gca,'FontSize',16)

% print
if nzlev==0
  switch myPlotFormat
    case 'eps'
%     print('-depsc2',strcat(plocNow,ad_name,'_',...
%                     sprintf('%05d',ncount),'.eps'));
      saveas(gcf,strcat(plocNow,ad_name,'_',...
                 sprintf('%05d',ncount),'.eps'),'epsc2')
    case 'jpg'
%     print('-djpeg90',strcat(plocNow,ad_name,'_',...
%                      sprintf('%05d',ncount),'.jpg'));
      saveas(gcf,strcat(plocNow,ad_name,'_',...
                 sprintf('%05d',ncount),'.jpg'),'jpg')
    otherwise
      warning('myPlotFormat not set correctly, skipping print step')
  end
elseif nzlev>0
  switch myPlotFormat
    case 'eps'
%     print('-depsc2',strcat(zplocNow,ad_name,'_',sprintf('%05d',ncount),...
%                        '_z',sprintf('%02d',zlevs(nzlev)),'.eps'));
      saveas(gcf,strcat(zplocNow,ad_name,'_',sprintf('%05d',ncount),...
                        '_z',sprintf('%02d',zlevs(nzlev)),'.eps'),'epsc2');
    case 'jpg'
%     print('-djpeg90',strcat(zplocNow,ad_name,'_',sprintf('%05d',ncount),...
%                       '_z',sprintf('%02d',zlevs(nzlev)),'.jpg'));
      saveas(gcf,strcat(zplocNow,ad_name,'_',sprintf('%05d',ncount),...
                        '_z',sprintf('%02d',zlevs(nzlev)),'.jpg'),'jpg');
    otherwise
      warning('myPlotFormat not set correctly, skipping print step')
  end
else
  warning('nzlev not set, plot not printed')
end

% clear current figure window (attempt to stem memory leak)
% this seems to work - without this, we have a serious memory leak
cla;
