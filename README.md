# AdjointAnalysis
Create animations, plots, and calculate summary statistics for MITgcm adjoint output

% steps

1.) Download/place experiment data (see directory_structure.txt for assumed structure)

2.) Change 'nrecords' in each adxx*meta file to max number (e.g. 523) 
 
3.) In experiment folder, create list of iterations for both 
    forward and adjoint snapshots. Call files "its_ad.txt" and "its.txt".

4.) If you want to use masks for regional analysis, create the masks and put them in the 'masks' 
    directory. Also create "list_of_masks.txt" file, with locations of 
    each mask. Keep that in the directory where you run analysis code.

5.) Change the paths and settings in main.m as desired to set location of 
    experiment, stdevs, and where you want the plots/data to go afterwards.

6.) Run "main" to get the analysis going.
