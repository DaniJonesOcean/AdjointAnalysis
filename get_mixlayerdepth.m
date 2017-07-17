function mld_now = get_mixlayerdepth(record,fwdroot,fwddir)
% get mixed layer depth for this record
% INPUTS:
% record: model time step to load
% fwdroot: root directory for forward run
% fwddir: experiment for fwd run
% OUTPUT:
% mld_now: mixed layer depth at time step [record] from experiment [fwddir]
%
% name for rdmds2gcmfaces call
mld_location = strcat(fwdroot,'experiments/',fwddir,'diag_2D_set1');
% load mld
mld_now = rdmds2gcmfaces(mld_location,record,'rec',1);

end     
