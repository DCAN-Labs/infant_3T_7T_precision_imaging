clear all
%ad relavant paths
addpath(genpath('/myfolder/utilities/cifti-matlab'));
wb_command='/myfolder/utilities/workbench/1.4.2/workbench/bin_rh_linux64/wb_command';

% example inputs
%%%%%%%%%%%%%%%%%%%
MIN=10;
SES='MENORDIC';
TASK='oddball';
ACQ='7T16mm';
SUB='1012';
PERM=[1:100]; %number of permutations run
%%%%%%%%%%%%%%%%%%%%
% load data
path=['/myfolder/stability/sub-' SUB ];

for k=1:size(PERM,2)
         
     input=[path '/perm' num2str(k) '/rel_val_sub-' SUB '_ses-' SES '_acq-' ACQ '_' num2str(MIN) 'min_with_' num2str(MIN) 'min_SMOOTHED_2.25_perm' num2str(PERM(k)) '.txt'];
      all_rel_val(:,k)=load(input);
end
save([path '/dense_rel_val_matrix_sub-' SUB '_ses-' SES '_acq' ACQ '_' num2str(MIN) 'min_with_' num2str(MIN) '.mat'], 'all_rel_val');

% take any dscalar as an example just to have the dimension information
example_dscalar = cifti_read(['/myfolder/test.dscalar.nii']);

example_dscalar.cdata=squeeze(nanmean(all_rel_val,2));
dscalar_name=['sub-' SUB '_ses-' SES '_acq-' ACQ '_' num2str(MIN) 'min_with_' num2str(MIN) 'min_SMOOTHED_2.25_.dscalar.nii'];
cifti_write(example_dscalar, [path '/' dscalar_name]);

