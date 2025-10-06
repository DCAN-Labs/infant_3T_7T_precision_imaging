function quantify_connectivity_diff_by_structure_subcortex(infolder, dconn3T, dconn7T)
addpath(genpath('/myfolder/utilities/cifti-matlab'));
addpath(genpath('/myfolder/utilities/gifti/'));
wb_command='/myfolder/utilities/workbench/1.4.2/workbench/bin_rh_linux64/wb_command';


%% read in dconns
subidx=strfind(dconn3T, 'sub-');
sesidx=strfind(dconn3T, 'ses-');
taskidx=strfind(dconn3T, 'task');
acqidx=strfind(dconn3T, 'acq-');
echoidx=strfind(infolder, 'combined_')+ size('combined_', 2);
echo=infolder(echoidx:end);
sub=dconn3T(subidx:sesidx-2);
ses=dconn3T(sesidx:taskidx-2);
%acq=dconn3T(acqidx:acqidx+9);

dconn3 = cifti_read([infolder '/' dconn3T]);
diminfo1=dconn3.diminfo;
data=dconn3.cdata;
% exclude diagonal
data(data>7)=NaN;
%data=[data,data,data];%to make example a matrix for testing purposes
clear dconn3

%split dconn into the different brain areas
cort_start=diminfo1{1,1}.models{1,1}.start;
cort_stop=diminfo1{1,1}.models{1,2}.start+diminfo1{1,1}.models{1,2}.count-1;
 % 2. cerebellum
cereb_start=diminfo1{1,1}.models{1,10}.start;
cereb_stop=diminfo1{1,1}.models{1,11}.start+diminfo1{1,1}.models{1,11}.count-1;
 % 2. subcortex
subc_start1=diminfo1{1,1}.models{1,3}.start;
subc_stop1=diminfo1{1,1}.models{1,9}.start+diminfo1{1,1}.models{1,9}.count-1;
subc_start2=diminfo1{1,1}.models{1,12}.start;
subc_stop2=diminfo1{1,1}.models{1,21}.start+diminfo1{1,1}.models{1,21}.count-1;

dconntri=tril(abs(data));
clear data
% include all data that involves the subcortex
dconntrisubc=dconntri(subc_start1:subc_stop1, :);
dconn_vector1=reshape(dconntrisubc(dconntrisubc>0),sum(sum(dconntrisubc>0)),1);
clear dconntrisubc

dconntrisubc=dconntri(cereb_start:cereb_stop, subc_start1:subc_stop1);
dconn_vector2=reshape(dconntrisubc(dconntrisubc>0),sum(sum(dconntrisubc>0)),1);
clear dconntrisubc

dconntrisubc=dconntri(subc_start2:subc_stop2, :);
dconn_vector3=reshape(dconntrisubc(dconntrisubc>0),sum(sum(dconntrisubc>0)),1);
clear dconntrisubc

dconn_vector=[dconn_vector1; dconn_vector2; dconn_vector3];

%clear dconn_vector
clear dconn_vector1
clear dconn_vector2
clear dconn_vector3

clear dconntri

dconn7 = cifti_read([infolder '/' dconn7T]);
data7=dconn7.cdata;
% exclude diagonal
data7(data7>7)=NaN;
%data=[data,data,data];%to make example a matrix for testing purposes
clear dconn7
dconntri=tril(abs(data7));
clear data7

dconntrisubc=dconntri(subc_start1:subc_stop1, :);
dconn_vector1=reshape(dconntrisubc(dconntrisubc>0),sum(sum(dconntrisubc>0)),1);
clear dconntrisubc

dconntrisubc=dconntri(cereb_start:cereb_stop, subc_start1:subc_stop1);
dconn_vector2=reshape(dconntrisubc(dconntrisubc>0),sum(sum(dconntrisubc>0)),1);
clear dconntrisubc

dconntrisubc=dconntri(subc_start2:subc_stop2, :);
dconn_vector3=reshape(dconntrisubc(dconntrisubc>0),sum(sum(dconntrisubc>0)),1);
clear dconntrisubc

dconn_vector7=[dconn_vector1; dconn_vector2; dconn_vector3];

%clear dconn_vector
clear dconn_vector1
clear dconn_vector2
clear dconn_vector3

clear dconntri
% clear dconn_vector

tablevars=["mean"; "sd"; "median"; "5thpercentile";"95thpercentile"];
stats3T=[mean(dconn_vector); std(dconn_vector); median(dconn_vector); prctile(dconn_vector, 5); prctile(dconn_vector, 95)];
stats7T=[mean(dconn_vector7); std(dconn_vector7); median(dconn_vector7); prctile(dconn_vector7, 5); prctile(dconn_vector7, 95)];

stats=table(tablevars, stats3T, stats7T);
writetable(stats, ['/myfolder/connectivity_strength/' sub '_' ses '_' echo '_histogram_stats_subcortex.csv'])


end
