%
% attempt at general 'summary stats' code
%
% called by the 'main.m' script
%

% display
disp('--')
disp('-- Entering generic_stats.m')
disp('--')

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
    disp('----')
    disp('---- no stdev file selected/found')
    disp('----')
  end

  % if selected, create video object for animation
  if goMakeAnimations==1
    vidObj = VideoWriter(strcat(aloc,ad_name));
    open(vidObj);
  else
    disp('----')
    disp('---- note :: no animations will be created')
    disp('----')
  end

  % load adj and sensitivity field
  switch ad_name(1:3)
    case 'adx'
      disp('----')
      disp('---- file type: adxx')
      disp('----')
      handle_adxx_files
    case 'ADJ'
      disp('----')
      disp('---- file type: ADJ')
      disp('----')
      handle_ADJ_files 
    otherwise
      warning('---- unexpected adjoint sensitivity field name')
  end

  % close video object
  if goMakeAnimations==1
    close(vidObj);
  end

end
