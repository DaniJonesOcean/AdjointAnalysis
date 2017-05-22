
% initial setup
%initial_setup

% iterations for 2008
load('its2008.txt')

% north atlantic mask
msk = read_bin('masks/ulsw_maskC');

% get data
A = rdmds2gcmfaces(strcat(floc,'diag_3D_set2'),its2008','rec',3);
B = squeeze(nanmean(A,4));
C = gcmfaces_subset(msk,B);
drhodr = squeeze(nanmean(C,1));

% make plot
figure('color','w','position',[674 49 515 736])
plot(abs(drhodr),mygrid.RC,'color',[0.0 0.0 0.6],'linewidth',3.0)
set(gca,'ylim',[-3000 -100])
set(gca,'xlim',[0.0 0.3e-3])
hx=xlabel('|d\rho/dr| (kg/m^4)');
hy=ylabel('Detph (m)');
ht=title('Labrador Sea stratification');
set([hx,hy,ht],'FontSize',16)
set(gca,'fontsize',14)
set(gca,'xgrid','on','ygrid','on')

set(gcf,'PaperPositionMode','auto')

print('-depsc2','labsea_stratification.eps')
print('-djpeg90','labsea_stratification.jpg')
