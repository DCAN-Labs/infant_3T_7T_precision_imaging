#!/bin/bash -l

#SBATCH -J cifti-con-heatmap
#SBATCH --ntasks=64
#SBATCH --tmp=750gb
#SBATCH --mem=240gb
#SBATCH -t 24:00:00
#SBATCH --mail-type=ALL
#SBATCH -p msismall,agsmall,ag2tb,msibigmem,msilarge,aglarge
#SBATCH -o output_logs/rel_heatmap_%A_%a.out
#SBATCH -e output_logs/rel_heatmap_%A_%a.err
#SBATCH -A user

# inputs according to BIDS naming scheme
SUB=${1} # subject ID
SES=${2}
TASK=${3} # task - determine if SE or ME and NORDIC or non-NORDIC
ACQ=${4}
MIN=${5} # define up to how many minutes should be compared. In this case 10
NUM=${6} #permutation number - in this case 1 to 100
FD=0.3 # FD for this dataset
S_KERNEL=2.25


#############################################################################################
# HARDCODED INPUTS
DIR=/myfolder/XCP-D_derivatives/ION${SUB}_${SES}_combined/sub-${SUB}/ses-${SES}
FILE=/func/sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_space-fsLR_den-91k_desc-denoised_bold.dtseries.nii
motion_filename=/func/sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_desc-abcc_qc
# in case file is shortened to a subset of runs, a renamed file can be put in
#FILE=sub-${SUB}_runs-${RUNS}_acq-${ACQ}_dense.dtseries.nii
#motion_filename=sub-${SUB}_runs-${RUNS}_acq-${ACQ}_motion_mask
surf_L=${DIR}/anat/sub-${SUB}_ses-${SES}_hemi-L_space-fsLR_den-32k_desc-hcp_midthickness.surf.gii
surf_R=${DIR}/anat/sub-${SUB}_ses-${SES}_hemi-R_space-fsLR_den-32k_desc-hcp_midthickness.surf.gii
RESULTSDIR=/myfolder/stability/sub-${SUB}/perm${NUM}

if [ ! -d ${RESULTSDIR} ]; then
	mkdir -p ${RESULTSDIR}
fi
#paths to matlab runtime and wb_command
MRE_DIR='/myfolder/utilities/MATLAB_MCR/v91/'
WB_CMD='/myfolder/utilities/workbench/1.4.2/workbench/bin_rh_linux64/wb_command'
CIFTI_C='/myfolder/utilities/cifti-matlab' 
GIFTI_C='/myfolder/utilities/gifti/'
#############################################################

module load workbench; 
module load matlab; 

# create temporary work dir for permutations
work_dir=/tmp/sub-${SUB}/acq-${ACQ}/perm${NUM}/dconn/SMOOTHED_${S_KERNEL}

pwd; hostname; date

if [ ! -d ${work_dir} ]; then
	mkdir -p ${work_dir}
fi

#grep TR from timeseries
TR=$(wb_command -file-information ${DIR}/${FILE} -only-step-interval) 

# transform XCP-D motion file to DCAN motion file (if it doesn't exist yet)
if ! [ -f ${DIR}/${motion_filename}_power_2014_FD_only.mat ]; then

  matlab -nodisplay -nosplash -r "addpath('/myfolder/utilities/xcpd2dcanmotion/'); xcpd2dcanmotion('${DIR}/${motion_filename}.hdf5'); exit;";

fi

matlab -nodisplay -nosplash -r "addpath('/myfolder/stability'); shuffle_data_for_heatmap('${SUB}', '${SES}', ${FD}, '${TASK}', ${TR}, ${MIN}, ${NUM}, '${DIR}', '${DIR}/${motion_filename}_power_2014_FD_only.mat', '${FILE}', '${work_dir}'); exit;";

new_timeseries=${work_dir}/sub-${SUB}_ses-${SES}_task-${TASK}_bold_shuffled_timeseries.dtseries.nii
new_motion_file=${work_dir}/sub-${SUB}_ses-${SES}_task-${TASK}_desc-filtered_motion_mask.mat


OUTDIR=${work_dir}/rel_val/
if [ ! -d ${OUTDIR} ]; then
	mkdir -p ${OUTDIR}
fi


MINVAR=$(seq 1 ${MIN}); 

for X1 in ${MINVAR}; do

mask_h1=${work_dir}/masks/sub-${SUB}_ses-${SES}_mask_half1_${X1}min.txt
if [ ! -d ${work_dir}/half1/${X1}min ]; then
	mkdir -p ${work_dir}/half1/${X1}min
fi

#run cifti-con for half1 
#cifticonn wrapper: https://github.com/DCAN-Labs/cifti-connectivity
python3 /myfolder/utilities/cifti_connectivity/cifti_conn_wrapper.py \
--motion ${new_motion_file} \
--additional-mask ${mask_h1} \
--mre-dir ${MRE_DIR} \
--left ${surf_L} \
--right ${surf_R} \
--smoothing-kernel ${S_KERNEL} \
--wb-command ${WB_CMD} --fd-threshold ${FD} \
${new_timeseries} \
${TR} ${work_dir}/half1/${X1}min matrix;

for X2 in ${MINVAR}; do


mask_h2=${work_dir}/masks/sub-${SUB}_ses-${SES}_mask_half2_${X2}min.txt


if [ ! -d ${work_dir}/half2/${X2}min ]; then
	mkdir -p ${work_dir}/half2/${X2}min
fi

#run code for half 2
#cifticonn wrapper: https://github.com/DCAN-Labs/cifti-connectivity
python3 /myfolder/utilities/cifti_connectivity/cifti_conn_wrapper.py \
--motion ${new_motion_file} \
--additional-mask ${mask_h2} \
--mre-dir ${MRE_DIR} \
--left ${surf_L} \
--right ${surf_R} \
--smoothing-kernel ${S_KERNEL} \
--wb-command ${WB_CMD} --fd-threshold ${FD} \
${new_timeseries} \
${TR} ${work_dir}/half2/${X2}min matrix;

D_ONE=${work_dir}/half1/${X1}min/sub-${SUB}_ses-${SES}_task-${TASK}_bold_shuffled_timeseries_SMOOTHED_${S_KERNEL}.dtseries.nii_all_frames_at_FD_${FD}.dconn.nii

D_TWO=${work_dir}/half2/${X2}min/sub-${SUB}_ses-${SES}_task-${TASK}_bold_shuffled_timeseries_SMOOTHED_${S_KERNEL}.dtseries.nii_all_frames_at_FD_${FD}.dconn.nii

OUTNAME=rel_val_sub-${SUB}_ses-${SES}_acq-${ACQ}_${X1}min_with_${X2}min_SMOOTHED_${S_KERNEL}_perm${NUM}

#code https://github.com/DCAN-Labs/code_infant_me_nordic_paper/blob/main/reliability/CalculateDconntoDconnCorrelationIndividualSeedsNoDistMat.m
matlab -nodisplay -nosplash -r  "addpath('/myfolder/code/'); CalculateDconntoDconnCorrelationIndividualSeedsNoDistMat('DconnShort','${D_ONE}','DconnGroundTruth','${D_TWO}', 'OutputDirectory','${OUTDIR}', 'OutputName','${OUTNAME}', 'wb_command','${WB_CMD}', 'CIFTI_path','${CIFI_C}', 'GIFTI_path','${GIFI_C}'); exit;"

cp ${OUTDIR}/${OUTNAME}.txt ${RESULTSDIR}/${OUTNAME}.txt;

done;
done
