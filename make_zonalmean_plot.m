% make_zonalmean_plot
% -- need to add axis limits, including color axis limits

% use figure hf2
figure(hf2)

% field to be plotted (sum up dJs)
[Fxplot,xx,yy,weightOut] = calc_zonsum_dJ(dJfield,1,'dJ');

% contour plot
contourf(xx,yy,Fxplot);
% --- will need to add stuff to fix axes limits and such

% name string formatting
tempS = ad_name;
tempR = strrep(tempS,'_',' ');

% title and date
title(strcat(strrep('Zonal sum ',ad_name,'_',' '),' :: ',...
             sprintf('%8.2f',ndays(ncount)./365),' years'));
%m_text(0,-80,datestr(date_num(ncount),1))

% prepare to plot
orig_mode = get(gcf, 'PaperPositionMode');
set(gcf, 'PaperPositionMode', 'auto');
cdata = hardcopy(gcf, '-Dzbuffer', '-r0');
set(gcf, 'PaperPositionMode', orig_mode);
%currFrame = im2frame(cdata);
%writeVideo(vidObj,currFrame);

% print
print('-djpeg90',strcat(ploc,'zonalSum_',ad_name,'_',sprintf('%05d',ncount),'.jpg'));

% clear current figure window (attempt to stem memory leak)
cla;

% reset back to hf1 (2D plots)
figure(hf1)
