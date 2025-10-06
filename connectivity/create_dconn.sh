#!/bin/bash -l

#SBATCH -J dconn
#SBATCH --ntasks=4
#SBATCH --tmp=60gb
#SBATCH --mem=60gb
#SBATCH -t 02:00:00
#SBATCH --mail-type=ALL
#SBATCH --mail-user=NONE
#SBATCH -p msismall
#SBATCH -o output_logs/dconn_%A_%a.out
#SBATCH -e output_logs/dconn_%A_%a.err
#SBATCH -A user

SUB=${1}
SES=${2}
TASK=${3}  #oddball
ACQ=${4}
FD=0.3
BOLD=denoised #options based on XCP-D outputs from various versions: 'denoised' or 'denoisedSmoothed' 'interpolated' 
S_KERNEL=2.25

work_dir=/tmp/${SUB}/${SES}/${TASK}/${BOLD}/
in_dir=/myfolder/XCP-D_derivatives/ION${SUB}_${SES}_combined
out_dir=/myfolder/ION_dconns_combined

MRE_DIR='/myfolder/utilities/MATLAB_MCR/v91/'
WB_CMD='/myfolder/utilities/workbench/1.4.2/workbench/bin_rh_linux64/wb_command'



if [ ! -d ${work_dir} ]; then
	mkdir -p ${work_dir}

fi

if [ ! -d ${out_dir} ]; then
	mkdir -p ${out_dir}

fi
module load workbench; 
module load matlab;     

TR=$(wb_command -file-information ${in_dir}/sub-${SUB}/ses-${SES}/func/sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_space-fsLR_den-91k_desc-${BOLD}_bold.dtseries.nii -only-step-interval) 

# transform XCP-D motion file to DCAN motion file. This is the motion .mat output filetype thet has been common in th ABCD-BIDS pipeline
#https://github.com/DCAN-Labs/xcpd2dcanmotion
if ! [ -f ${in_dir}/sub-${SUB}/ses-${SES}/func/sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_desc_abcc_qc_power_2014_FD_only.mat ]; then
matlab -r "addpath('/myfolder/utilities/xcpd2dcanmotion/'); xcpd2dcanmotion('${in_dir}/sub-${SUB}/ses-${SES}/func/sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_desc-abcc_qc.hdf5', '${work_dir}')";
fi

#cifticonn wrapper: https://github.com/DCAN-Labs/cifti-connectivity
#run cifti-con for half1 part of data
python3 /myfolder/cifti_connectivity/cifti_conn_wrapper.py \
--motion ${work_dir}/*.mat \
--mre-dir ${MRE_DIR} \
--left ${in_dir}/sub-${SUB}/ses-${SES}/anat/sub-${SUB}_ses-${SES}_hemi-L_space-fsLR_den-32k_desc-hcp_midthickness.surf.gii \
--right ${in_dir}/sub-${SUB}/ses-${SES}/anat/sub-${SUB}_ses-${SES}_hemi-R_space-fsLR_den-32k_desc-hcp_midthickness.surf.gii \
--wb-command ${WB_CMD} --fd-threshold ${FD} --smoothing-kernel ${S_KERNEL} --remove-outliers \
${in_dir}/sub-${SUB}/ses-${SES}/func/sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_space-fsLR_den-91k_desc-${BOLD}_bold_spatially_interpolated.dtseries.nii \
${TR} ${out_dir} matrix;

