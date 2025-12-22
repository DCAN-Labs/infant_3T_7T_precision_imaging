
% step 1 read in data
clear all
addpath(genpath('/myfolder/utilities/cifti-matlab'));
addpath(genpath('/myfolder/utilities/gifti/'));
wb_command='/myfolder/utilities/workbench/1.4.2/workbench/bin_rh_linux64/wb_command';

%example inputs
%%%%%%%%%%
SUB='PB020';
SES='MENORDIC';
ACQ='7T16mm';
%%%%%%%%%%%%%

base_folder='/myfolder/T2star';
%% get rid of medial wall
% load example giftis that define medial wall as this is not well defined in data generated in previous step. 
example_file_R = gifti('tpl-fsLR_hemi-R_den-32k_desc-nomedialwall_dparc.label.gii');
data_array_R=example_file_R.cdata;
example_file_L = gifti('tpl-fsLR_hemi-L_den-32k_desc-nomedialwall_dparc.label.gii');
data_array_L=example_file_R.cdata;
%% read in data (loop over good runs and average)
cd(base_folder);
filelist=dir(['sub-' SUB '/acq-' ACQ '*/cifti_mni/surface*']);
%remove runs if necessary - e.g. high motion runs for PB0022
%filelist=filelist([1:4,6:10],:);

for n=1:size(filelist,1)
    sub_struct = cifti_read([filelist(n,1).folder '/' filelist(n,1).name]);
    sub1=sub_struct.cdata;
    sub1(~logical([data_array_L;data_array_R]))=NaN;
    sub_all(:,n)=sub1;
end
sub=mean(sub_all,2);



%% plot surfaces 
% plot surfaces for T2*
ciftiT2star=sub_struct;
ciftiT2star.cdata=sub;

cifti_write(ciftiT2star, ['sub-' SUB '/sub-' SUB '_ses-' SES '_acq-' ACQ '_run-average_T2star.dscalar.nii']);


% Histograms
save([base_folder '/sub-' SUB '/sub-' SUB '_acq-' ACQ '_T2star_average_val.mat'], 'sub');

% create histogram after saving data for 3T and 7T
clear all
base_folder='/myfolder/T2star';
SUB='PB022'
cd([base_folder '/sub-' SUB '/'])
load(['sub-' SUB '_acq-3T2mm_T2star_average_val.mat']);
sub_3T=sub;
load(['sub-' SUB '_acq-7T16mm_T2star_average_val.mat']);
sub_7T=sub;

figure;
set(gcf,'color','white')
xlabel('T2* times in seconds')
ylabel('voxel count surface')
xlim([0 0.25])
ylim([0 11000])
xl1=xline(0.014,'-',{'echo 1'}, 'color', '#FEC503', 'LineWidth', 2);
xl1.LabelVerticalAlignment = 'middle';
xl1.LabelHorizontalAlignment = 'center';
xl1.FontSize = 12;
hold on
xl2=xline(0.039,'-',{'echo 2'}, 'color', '#FEC503', 'LineWidth', 2);
xl2.LabelVerticalAlignment = 'middle';
xl2.LabelHorizontalAlignment = 'center';
xl2.FontSize = 12;
xl3=xline(0.064,'-',{'echo 3'}, 'color', '#FEC503', 'LineWidth', 2);
xl3.LabelVerticalAlignment = 'top';
xl3.LabelHorizontalAlignment = 'center';
xl3.FontSize = 12;
xl4=xline(0.088,'-',{'echo 4'}, 'color', '#FEC503', 'LineWidth', 2);
xl4.LabelVerticalAlignment = 'top';
xl4.LabelHorizontalAlignment = 'center';
xl4.FontSize = 12;
xl5=xline(0.014,'-',{'echo 1'}, 'color', '#7E2F8E', 'LineWidth', 2);
xl5.LabelVerticalAlignment = 'top';
xl5.LabelHorizontalAlignment = 'center';
xl5.FontSize = 12;
xl6=xline(0.035,'-',{'echo 2'}, 'color', '#7E2F8E', 'LineWidth', 2);
xl6.LabelVerticalAlignment = 'top';
xl6.LabelHorizontalAlignment = 'center';
xl6.FontSize = 12;
xl7=xline(0.057,'-',{'echo 3'}, 'color', '#7E2F8E', 'LineWidth', 2);
xl7.LabelVerticalAlignment = 'top';
xl7.LabelHorizontalAlignment = 'center';
xl7.FontSize = 12;
set(gca,'fontsize', 15)
histogram(sub_3T, 'BinWidth', 0.003, 'FaceColor', '#FEC503', FaceAlpha=0.7);
histogram(sub_7T, 'BinWidth', 0.003, 'FaceColor', '#7E2F8E', FaceAlpha=0.7);
box off
legend('','','','','','','', '3T','7T') 
%%
%add stats
sub_3T_ms=sub_3T*1000;
sub_7T_ms=sub_7T*1000;
table_37=[sub_3T_ms, sub_7T_ms];
%stats
for i=1:2
    stats(1,i)=nanmean(table_37(:,i)); %mean
    stats(2,i)=nanstd(table_37(:,i)); %standard deviation
    stats(3,i)=prctile(table_37(:,i),5); %5th percentile
    stats(4,i)=prctile(table_37(:,i),95); %95th percentile
    stats(5,i)=nanmedian(table_37(:,i)); %median

end

