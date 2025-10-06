clear all
close all

% example inputs
%%%%%%%%%%%%%%
ACQ='3T2mm';
SUB='1012';
SES='MENORDIC';
%%%%%%%%%%%%%%


infolder=['/myfolder/stability/sub-' SUB];


for p=1:100
for s=1:10
    for m=1:10
        infile=['rel_val_sub-' SUB '_ses-' SES '_acq-' ACQ '_' num2str(s) 'min_with_' num2str(m) 'min_SMOOTHED_2.25_perm' num2str(p) '.txt'];
        rel_val=load([infolder '/perm' num2str(p) '/' infile]);
        avg_rel_val=nanmean(rel_val);
        rel_val_mat(s,m)=avg_rel_val;
    end
end
rel_val_mat_all(:,:,p)=rel_val_mat;
end
save([infolder '/rel_val_sub-' SUB '_ses-' SES '_acq-' ACQ '_heatmap_10min_100perm__SMOOTHED_2.25.mat'], 'rel_val_mat_all');

rel_val_mat_mean=squeeze(mean(rel_val_mat_all,3));
rel_val_mat_sd=squeeze(std(rel_val_mat_all,[],3));



%% plots for cortex, subcortex and cerebellum
clear all
close all

%example inputs
%%%%%%%%%%%%%%%
SUB='1012';
SES='MENORDIC';
ACQ='3T2mm';
%%%%%%%%%%%%%%%

infolder=['/myfolder/stability/sub-' SUB];


addpath(genpath('/myfolder/utilities/cifti-matlab'));
wb_command='/myfolder/utilities/workbench/1.4.2/workbench/bin_rh_linux64/wb_command';

% take any dscalar as an example just to have the dimension information
example_dscalar = cifti_read(['/myfolder/test.dscalar.nii']);
% 1. cortex
cort_start=example_dscalar.diminfo{1,1}.models{1,1}.start;
cort_stop=example_dscalar.diminfo{1,1}.models{1,2}.start+example_dscalar.diminfo{1,1}.models{1,2}.count-1;
% 2. cerebellum
cereb_start=example_dscalar.diminfo{1,1}.models{1,10}.start;
cereb_stop=example_dscalar.diminfo{1,1}.models{1,11}.start+example_dscalar.diminfo{1,1}.models{1,11}.count-1;
% 2. subcortex
subc_start1=example_dscalar.diminfo{1,1}.models{1,3}.start;
subc_stop1=example_dscalar.diminfo{1,1}.models{1,9}.start+example_dscalar.diminfo{1,1}.models{1,9}.count-1;
subc_start2=example_dscalar.diminfo{1,1}.models{1,12}.start;
subc_stop2=example_dscalar.diminfo{1,1}.models{1,21}.start+example_dscalar.diminfo{1,1}.models{1,21}.count-1;


for p=1:100
for s=1:10
    for m=1:10
        infile=['rel_val_sub-' SUB '_ses-' SES '_acq-' ACQ '_' num2str(s) 'min_with_' num2str(m) 'min_SMOOTHED_2.25_perm' num2str(p) '.txt'];
         rel_val=load([infolder '/perm' num2str(p) '/' infile]);
        avg_rel_val_cort=nanmean(rel_val(cort_start:cort_stop,:));
        rel_val_mat_cort(s,m)=avg_rel_val_cort;
        avg_rel_val_cereb=nanmean(rel_val(cereb_start:cereb_stop,:));
        rel_val_mat_cereb(s,m)=avg_rel_val_cereb;
        avg_rel_val_subc=nanmean(rel_val([subc_start1:subc_stop1,subc_start2:subc_stop2], :));
        rel_val_mat_subc(s,m)=avg_rel_val_subc;
    end
end
rel_val_mat_all_cort(:,:,p)=rel_val_mat_cort;
rel_val_mat_all_cereb(:,:,p)=rel_val_mat_cereb;
rel_val_mat_all_subc(:,:,p)=rel_val_mat_subc;
end

save([infolder '/rel_val_cortex_sub-' SUB '_ses-' SES '_acq-' ACQ '_heatmap_10min_100perm_SMOOTHED_2.25.mat'], 'rel_val_mat_all_cort');
save([infolder '/rel_val_cerebellum_sub-' SUB '_ses-' SES '_acq-' ACQ '_heatmap_10min_100perm_SMOOTHED_2.25.mat'], 'rel_val_mat_all_cereb');
save([infolder '/rel_val_subcortex_sub-' SUB '_ses-' SES '_acq-' ACQ '_heatmap_10min_100perm_SMOOTHED_2.25.mat'], 'rel_val_mat_all_subc');

rel_val_mat_mean_cort=squeeze(mean(rel_val_mat_all_cort,3));
rel_val_mat_mean_cereb=squeeze(mean(rel_val_mat_all_cereb,3));
rel_val_mat_mean_subc=squeeze(mean(rel_val_mat_all_subc,3));

figure; set(gcf,'color','w');
imagesc(rel_val_mat_mean_cort); colorbar; colormap(jet)
caxis([0 0.5])
set(gca,'YDir','normal')
title('stability cortex')
fontsize(16,"points")

figure; set(gcf,'color','w');
imagesc(rel_val_mat_mean_cereb); colorbar; colormap(jet)
caxis([0 0.5])
set(gca,'YDir','normal')
title('stability cerebellum')
fontsize(16,"points")

figure; set(gcf,'color','w');
imagesc(rel_val_mat_mean_subc); colorbar; colormap(jet)
caxis([0 0.5])
set(gca,'YDir','normal')
title('stability subcortex')
fontsize(16,"points")
