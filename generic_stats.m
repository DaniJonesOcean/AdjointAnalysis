%
% attempt at general 'summary stats' code
%
% called by the 'main.m' script
%

% display
disp('-- Entering generic_stats')

% load text file of adj fields and sigmas
filename = strcat(floc,'adj_list.txt');
if exist(filename,'file')
  [A,delimiterOut]=importdata(filename);
  B=regexp(A,delimiterOut,'split');
else
  error('generic_stats: adj_list.txt file not found')
end

% load text file of adj fields, sigmas, and caxes
filename = strcat(floc,'adj_list.txt');
fileID = fopen(filename,'r');
formatSpec = '%s %s %f %f';

% load fixed caxes, if they exist
filename = strcat(floc,'adj_cax.txt');
if exist(filename,'file')
  cax_fixed = 1;
  [C,delimiterOut]=importdata(filename);
else
  cax_fixed = 0;
  warning('No adj_cax.txt file found, caxis not fixed')
end

% for each adxx/ADJ and sigma pair, load in data
for nvariable=1:length(B)

  % isolate sensitivity field and sigma field name
  ad_name = strrep(B{nvariable}{1},' ','');

  if length(B{nvariable})==2
    sigma_name = strrep(B{nvariable}{2},' ','');
  elseif length(B{nvariable})==1
    sigma_name = 'none';
  end

  % if it exists, load sigma (called Fsig)
  sfilename = strcat(sloc,sigma_name,'.mat');
  if exist(sfilename,'file')
    load(sfilename);
    doesSigmaExist = 1;
  else
    doesSigmaExist = 0;
    disp('-- No stdev file selected/found')
  end

  % create video object for animation
  vidObj = VideoWriter(strcat(aloc,ad_name));
  open(vidObj);

  % load adj and sensitivity field
  switch ad_name(1:3)
    case 'adx'
      disp('file type: adxx')
      handle_adxx_files
    case 'ADJ'
      disp('file type: ADJ')
      handle_ADJ_files 
    otherwise
      warning('Unexpected adjoint sensitivity field name')
  end

  % close video object
  close(vidObj);

end
