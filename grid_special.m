% load gcmfaces grid
gcmfaces_global;
grid_load(gloc,5,'compact',1);

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

