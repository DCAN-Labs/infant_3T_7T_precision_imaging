#!/bin/bash -l

# these inputs are matching the BIDS format coding of filenames for the present dataset
SUB=${1} #input subject ID
SES=MENORDIC
TASK=oddball
RUN=${2} #input run number
ACQ=${3} # input whether it is a 3T or 7T acquisistion

subjectID=sub-${SUB}

output_folder=/myfolder/T2star/sub-${SUB}/acq-${ACQ}_run-${RUN} # where outputs are supposed to go
mkdir -p ${output_folder}
#define inputs. surface and T2star map are needed
path_mri_processed_data=/myfolder/derivatives/XCP-D_derivatives/ION${SUB}_${SES}_combined/sub-${SUB}/ses-${SES}
t2star_map=/myfolder/derivatives/Nibabies_derivatives/ION${SUB}_${SES}/sub-${SUB}/ses-${SES}/func/sub-${SUB}_ses-${SES}_task-${TASK}_acq-${ACQ}_run-${RUN}_space-MNI152NLin6Asym_res-2_T2starmap.nii.gz

./from_vol_to_metric_in_mni_new_xcpd.sh ${path_mri_processed_data} ${SUB} ${SES} ${t2star_map} ${output_folder}
./code_metric_to_cifti_in_mni_acq.sh ${output_folder} ${ACQ} ${RUN}

