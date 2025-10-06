function quantify_connectivity_diff_by_structure(infolder, dconn3T, dconn7T)
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

dconn7 = cifti_read([infolder '/' dconn7T]);
data7=dconn7.cdata;
% exclude diagonal
data7(data7>7)=NaN;
%data=[data,data,data];%to make example a matrix for testing purposes
clear dconn7

dconntri=tril(abs(data));
clear data
dconn_vector=reshape(dconntri(dconntri>0),sum(sum(dconntri>0)),1);
clear dconntri
%writematrix(dconn_vector, [infolder '/' sub '_' ses '_' acq 'abs_dconn_all.txt'])
dconntri7=tril(abs(data7));
clear data7
dconn_vector7=reshape(dconntri7(dconntri7>0),sum(sum(dconntri7>0)),1);
clear dconntri7
% clear dconn_vector

tablevars=["mean"; "sd"; "median"; "5thpercentile";"95thpercentile"];
stats3T=[mean(dconn_vector); std(dconn_vector); median(dconn_vector); prctile(dconn_vector, 5); prctile(dconn_vector, 95)];
stats7T=[mean(dconn_vector7); std(dconn_vector7); median(dconn_vector7); prctile(dconn_vector7, 5); prctile(dconn_vector7, 95)];

stats=table(tablevars, stats3T, stats7T);
writetable(stats, ['/myfolder/connectivity_strength/' sub '_' ses '_' echo '_histogram_stats.csv'])


end
