#!/bin/bash -l

#SBATCH -J quantify_connectivity
#SBATCH --ntasks=8
#SBATCH --tmp=240gb
#SBATCH --mem=240gb
#SBATCH -t 03:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=NONE
#SBATCH -p msismall
#SBATCH -o output_logs/quantift_connectivity_%A_%a.out
#SBATCH -e output_logs/quantify_connectivity_%A_%a.err
#SBATCH -A user


module load workbench/1.5.0
module load matlab

SUB=${1}
#ECHO=${2} #optimally or echo1, echo2, ...
SES=MENORDIC
TASK=oddball  #oddball
FD=0.3
BOLD=denoised #options: 'denoised' or 'denoisedSmoothed' 'interpolated' #depending on XCPD outputs/version
S_KERNEL=2.25
ACQ3T=3T2mm
ACQ7T=7T16mm

in_folder=/myfolder/ION_dconns_combined

dconn_in=sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ3T}_space-fsLR_den-91k_desc-${BOLD}_bold_spatially_interpolated_SMOOTHED_${S_KERNEL}.dtseries.nii_all_frames_at_FD_${FD}.dconn.nii
dconn_in2=sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ7T}_space-fsLR_den-91k_desc-${BOLD}_bold_spatially_interpolated_SMOOTHED_${S_KERNEL}.dtseries.nii_all_frames_at_FD_${FD}.dconn.nii

# Call the MATLAB function directly
matlab -nodisplay -nosplash -r "addpath('/myfolder/code/connectivity_strength'); infile1='${in_folder}'; infile2='${dconn_in}'; infile3='${dconn_in2}'; quantify_connectivity_diff_whole_brain(infile1, infile2, infile3); exit;"

#same script can be used to call any of the other matlab functions (short, long, subcortex)

#for short and long, also add distance matrix
#dist_matrix=/myfolder/distance_matrix/sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ3T}_distance_matrix.mat

# Call the MATLAB function directly
#matlab -nodisplay -nosplash -r "addpath('/myfolder/code/connectivity_strength'); infile1='${in_folder}'; infile2='${dconn_in}'; infile3='${dconn_in2}'; infile4='${dist_matrix}'; quantify_connectivity_diff_by_distance_long(infile1, infile2, infile3, infile4); exit;"


