function create_dscalar_from_roi_v2(dconn, dist_mat, ROI_vertex_list_txt, outfolder)
%this version 2 outputs matrices for the connections between the regions of interest

addpath(genpath('/mypath/utilities/cifti-matlab'));
wb_command='/mypath/utilities/workbench/1.4.2/workbench/bin_rh_linux64/wb_command';

%extract names
subidx=strfind(dconn, 'sub-');
sesidx=strfind(dconn, 'ses-');
taskidx=strfind(dconn, 'task');
acqidx=strfind(dconn, 'acq-');
SUB=dconn(subidx:sesidx-2);
SES=dconn(sesidx:taskidx-2);
ACQ=dconn(acqidx:acqidx+9);

example_dscalar = cifti_read(['/mypath/test.dscalar.nii']); %example dscalar structure
ROI_vertex_list=load(ROI_vertex_list_txt); %txt document with list of veritces - fromat 1x number

load(dist_mat);
for i=1:size(ROI_vertex_list,2)
    ROI_vertex=ROI_vertex_list(1,i);
    dist_to_ROI=distances(ROI_vertex,:);
    [closex]=find(dist_to_ROI<=2.5);
    template=zeros(size(example_dscalar.cdata));
    template(closex)=1;
    template=logical(template);
    all_close_template(:,i)=template;
end
clear distance

%save template ROI regions to dscalar
template_regions=sum(all_close_template,2);

example_dscalar.cdata=template_regions;
cifti_write(example_dscalar, [outfolder '/' SUB '_' SES '_' ACQ '_template_regions_motor_strip_connectivity_right.dscalar.nii']);


%load dconn
full_dconn = cifti_read(dconn);
data=full_dconn.cdata;
clear full_dconn

%select vertices
for j=1:size(all_close_template, 2)
    for k=1:size(all_close_template, 2)
        template=all_close_template(:,k);
        template2=all_close_template(:,j);
        roi_connections=data(template,:); %extract connections from x-axis
        roi_square=roi_connections(:,template2); %extract connections from y axis - if x and y template is the same, it is the connection with itself
          if k==j
              %only true for within ROI connections
            mask = triu(true(size(roi_square)), 1); %mask upper triangle
            ROI_vector = roi_square(mask); %extract as vector
             avg_corr_vector=mean(ROI_vector);
             
          else
            ROI_vector=roi_square(:);
            avg_corr_vector=mean(ROI_vector);

          end
          correlations_ROIs{k,j}=ROI_vector;
          avg_corr_ROIs(k,j)=avg_corr_vector;

     end
end

% 
% clims=[0 1]
% imagesc(avg_corr_ROIs, clims)
% colorbar
%average them


%save values for avg and all values for reference
save([outfolder '/' SUB '_' SES '_' ACQ '_avg_corr_values_motor_strip_ROIs_right.mat'], 'avg_corr_ROIs')
writematrix(avg_corr_ROIs, [outfolder '/' SUB '_' SES '_' ACQ '_avg_corr_values_motor_strip_ROIs_right.csv'])
save([outfolder '/' SUB '_' SES '_' ACQ '_all_corr_values_motor_strip_ROIs_right.mat'], 'correlations_ROIs')


end
