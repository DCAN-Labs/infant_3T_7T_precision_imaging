#input 

#source from_vol_to_metric_in_mni.sh path_mri_processed_data subjectID output_folder

path_mri_processed_data=${1}
subj=${2}
ses=${3}
vol=${4}
output_folder=${5}


path_to_native_surface=${path_mri_processed_data}/anat/

base_surf_left=sub-${subj}_ses-${ses}_hemi-L_space-fsLR_den-32k_desc-hcp_midthickness.surf.gii
base_surf_right=sub-${subj}_ses-${ses}_hemi-R_space-fsLR_den-32k_desc-hcp_midthickness.surf.gii
              
base_white_left=sub-${subj}_ses-${ses}_hemi-L_space-fsLR_den-32k_white.surf.gii
base_pial_left=sub-${subj}_ses-${ses}_hemi-R_space-fsLR_den-32k_pial.surf.gii

base_white_right=sub-${subj}_ses-${ses}_hemi-R_space-fsLR_den-32k_white.surf.gii
base_pial_right=sub-${subj}_ses-${ses}_hemi-R_space-fsLR_den-32k_pial.surf.gii


path_to_vol=${output_folder}

out=${path_to_vol}/surfs_mni
mkdir ${out}
out_left=${out}/Left_surface.func.gii
out_right=${out}/Right_surface.func.gii

module load workbench

wb_command -volume-to-surface-mapping ${vol}\
 $path_to_native_surface/$base_surf_left ${out_left}\
 -ribbon-constrained\
 ${path_to_native_surface}/${base_white_left}\
 ${path_to_native_surface}/${base_pial_left}


wb_command -volume-to-surface-mapping ${vol}\
 $path_to_native_surface/$base_surf_right ${out_right}\
 -ribbon-constrained\
 ${path_to_native_surface}/${base_white_right}\
 ${path_to_native_surface}/${base_pial_right}

