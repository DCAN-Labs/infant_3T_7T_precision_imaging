#!/bin/bash -l

#SBATCH -J roi_dscalar
#SBATCH --ntasks=8
#SBATCH --tmp=120gb
#SBATCH --mem=120gb
#SBATCH -t 01:00:00
#SBATCH --mail-type=ALL
#SBATCH -p msismall
#SBATCH -o output_logs/roi_dscalar_%A_%a.out
#SBATCH -e output_logs/roi_dscalar_%A_%a.err


module load workbench/1.5.0
module load matlab

SUB=${1}
SES=MENORDIC
TASK=oddball  #oddball
task2=rest # for 1.25mm data
FD=0.3
BOLD=denoised #options: 'denoised' or 'denoisedSmoothed' 'interpolated'
S_KERNEL=2.25
ACQ=${2}


in_folder=/mypath/dconns
#Files: dense connectivity matrix (dconn), distance matrix - file containing matrix with distances between vertices, list of vertices
dconn=${in_folder}/sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_space-fsLR_den-91k_desc-${BOLD}_bold_spatially_interpolated_SMOOTHED_${S_KERNEL}.dtseries.nii_all_frames_at_FD_${FD}.dconn.nii
distance_matrix=/mypath/sub-${SUB}_ses-${SES}_task-${TASK}_acq-3T2mm_distance_matrix.mat
ROI_vertex_list=/mypath/ROI_vertex_list_ION${SUB}_right.txt

#ROI_vertex=28120 #ION0011

outfolder=/mypath/ROI_analysis

# Call the MATLAB function directly
matlab -nodisplay -nosplash -r "addpath('/mypath/code/ROI_analysis'); infile1='${dconn}'; infile2='${distance_matrix}'; infile3='${ROI_vertex_list}'; infile4='${outfolder}'; create_dscalar_from_roi_v2(infile1, infile2, infile3, infile4); exit;"



