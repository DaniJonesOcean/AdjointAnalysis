# AdjointAnalysis
Create animations, plots, and calculate summary statistics for MITgcm adjoint output

% steps

1.) Download/place experiment data

2.) Change 'nrecords' in each adxx*meta file to max number (523) 
 
3.) In experiment folder, create 'adj_list.txt' file, where
    each line is of the form "adj_var_name stdev_var_name", 
    separated by a blank space 

4.) In experiment folder, create list of iterations for both 
    forward and adjoint snapshots. Call files "its_ad.txt" and "its.txt".

5.) If you want to use masks, create the masks and put them in the 'masks' 
    directory. Also create "list_of_masks.txt" file, with locations of 
    each mask. Keep that in the directory where you run analysis code.

6.) Change the paths in "initial_setup" to reflect the location of the 
    experiment, stdevs, and where you want the plots/data to go afterwards.

7.) Run "main" to get the analysis going.
