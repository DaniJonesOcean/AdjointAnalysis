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
%for nvariable=1:length(B)
for nvariable=1:length(myAdjList)

  % isolate sensitivity field and sigma field name
% ad_name = strrep(B{nvariable}{1},' ','');
% if length(B{nvariable})==2
%   sigma_name = strrep(B{nvariable}{2},' ','');
% elseif length(B{nvariable})==1
%   sigma_name = 'none';
% end
  ad_name = myAdjList{nvariable};
  if ~isempty(mySigmaList{nvariable})
    sigma_name = mySigmaList{nvariable};
  else
    sigma_name = 'none';
  end

  % if Fsig exists, set appropriate flags
  % Fsig is loaded in handle_adxx or handle_ADJ
  sfilename = strcat(sloc,sigma_name,'.mat');
  if exist(sfilename,'file')
    %load(sfilename);
    doesSigmaExist = 1;
  else
    doesSigmaExist = 0;
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
      ad_file_type = 'adxx';
      disp('----')
      disp('---- file type: adxx')
      disp('----')
      %handle_adxx_files
    case 'ADJ'
      ad_file_type = 'ADJ';
      disp('----')
      disp('---- file type: ADJ')
      disp('----')
      %handle_ADJ_files 
    otherwise
      warning('---- unexpected adjoint sensitivity field name')
  end

  % adjoint sensitivity field analysis (adxx or ADJ)
  handle_adxx_files

  % close video object
  if goMakeAnimations==1
    close(vidObj);
  end

end
