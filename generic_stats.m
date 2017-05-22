%
% attempt at general 'summary stats' code
%
% called by the 'main.m' script
%

% display
disp('-- Entering generic_stats.m')

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
  if goMakeAnimations==1
    vidObj = VideoWriter(strcat(aloc,ad_name));
    open(vidObj);
  else
    disp('note :: no animations will be created')
  end

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
  if goMakeAnimations==1
    close(vidObj);
  end

end
