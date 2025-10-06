#!/bin/bash -l

#SBATCH -J afni_fwhm
#SBATCH --ntasks=8
#SBATCH --tmp=20gb
#SBATCH --mem=20gb
#SBATCH -t 01:30:00
#SBATCH --mail-type=NONE
#SBATCH -p msismall,msilarge,msibigmem,agsmall,ag2tb
#SBATCH -o output_logs/fwhm_%A_%a.out
#SBATCH -A user

#inputs are fiting to BIDS file naming for this study
SUB=${1} # subject ID
SES=${2}
TASK=${3}
ACQ=${4}
RUN=${5}

#inputs and outputs in MNI space
in_folder=/myfolder/Nibabies_derivatives/ION${SUB}_${SES}/sub-${SUB}/ses-${SES}/func
in_file=sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_run-${RUN}_space-MNI152NLin6Asym_res-2_desc-preproc_bold.nii.gz
automask_filename2=sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_run-${RUN}_space-space-MNI152NLin6Asym_res-2_desc-preproc_bold_automasked #this is how the automasked file will be named
out_file=sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_run-${RUN}_space-MNI152NLin6Asym_res-2_average_fwhm.txt # this will be the fielname of the output

#inputs and outputs in native space. note that the preprocessed dat in native space is in the Nibabies working directory and not the derivatives and will therefore be copied to a new location and renamed
in_file_native=/myfolder/Nibabies_work/ION${SUB}_${SES}/nibabies_25_0_wf/single_subject_sub-${SUB}_ses-${SES}_wf/bold_ses_${SES}_task_${TASK}_acq_${ACQ}_run_${RUN}_echo_1_wf/bold_native_wf/bold_t2smap_wf/t2smap_node/desc-optcom_bold.nii.gz
automask_filename=sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_run-${RUN}_space-native_desc-preproc_bold_automasked
out_file_native=sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_run-${RUN}_space-native_average_fwhm.txt

out_folder=/myfolder/smoothness/ION${SUB}
#mkdir -p ${out_folder}
cp ${in_file_native} ${out_folder}/sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_run-${RUN}_space-native_desc-preproc_bold.nii.gz

module load afni

#calculate automask native space
3dAutomask -apply_prefix ${out_folder}/${automask_filename} ${in_file_native};
3dAFNItoNIFTI -prefix ${out_folder}/${automask_filename} ${out_folder}/${automask_filename}+orig.HEAD;
gzip ${out_folder}/${automask_filename}.nii;
rm ${out_folder}/${automask_filename}+orig.HEAD;
rm ${out_folder}/${automask_filename}+orig.BRIK;

#calculate automask MNI space
3dAutomask -apply_prefix ${out_folder}/${automask_filename2} ${in_folder}/${in_file};
3dAFNItoNIFTI -prefix ${out_folder}/${automask_filename2} ${out_folder}/${automask_filename2}+tlrc.HEAD;
gzip ${out_folder}/${automask_filename2}.nii;
rm ${out_folder}/${automask_filename2}+tlrc.HEAD;
rm ${out_folder}/${automask_filename2}+tlrc.BRIK;


#calculate fwhm
3dFWHMx -combine -detrend -acf -input ${out_folder}/${automask_filename}.nii.gz > ${out_folder}/${out_file_native};
3dFWHMx -combine -detrend -acf -input ${out_folder}/${automask_filename2}.nii.gz > ${out_folder}/${out_file};
