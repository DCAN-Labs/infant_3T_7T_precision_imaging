function shuffle_data_for_heatmap(SUB, SES, FD, TASK, TR, MAXMIN, permnum, infolder, motionfile, infile, outfolder)
%rng('shuffle') % make sure random numbers are not the same
addpath(genpath('/myfolder/utilities/cifti-matlab'));
UNIT=1 % have 1 minute segments for shuffeling

%load concatenated time series
concatenated_timeseries=cifti_read([infolder '/' infile]);


%load motion file
load(motionfile);

%pick fd traces with fitting FD value
for i=1:size(motion_data,2)
    list_thresholds(i,1)=motion_data{1,i}.FD_threshold;
end
index=find(list_thresholds==FD);

fd_vector=motion_data{1,index}.frame_removal;

retained_frames=abs(fd_vector-1);
%% define unit for shuffeling
shuffle_by=round(UNIT*60/TR);
% create start and stop points for shuffeling
full_framelist=find(retained_frames);

%create array with starting and stopping point of frame list
frame_start=1;
i=1;
while size(full_framelist,1)-frame_start>=shuffle_by
    framelist_start(i,1)=full_framelist(frame_start);
    framelist_stop(i,1)=full_framelist(frame_start + shuffle_by)-1;
    frame_start=frame_start + shuffle_by;
    i=i+1;
end

%then re-arrange
for i=1:size(framelist_stop,1)
    data_by_minute{i}=concatenated_timeseries.cdata(:,framelist_start(i):framelist_stop(i));
end
data_by_minute{i+1}=concatenated_timeseries.cdata(:,framelist_stop(i)+1:end);
%% find random order for re-arranging data
%random_order1=randperm(size(framelist_stop,1));
load(['rand_order_' num2str(size(framelist_stop,1)) '_min.mat']);
random_order=rand_order_minutes(permnum,:);
%%
%rearrange data by minute to build new concatenated timeseries
k=1;
rearranged_data=[data_by_minute{1,random_order(k)}];
while k<size(framelist_stop,1)
rearranged_data=[rearranged_data, data_by_minute{1,random_order(k+1)}];
k=k+1;
end
rearranged_data=[rearranged_data, data_by_minute{1,end}];


new_timeseries=concatenated_timeseries;
new_timeseries.cdata=rearranged_data;
new_timeseries.diminfo{1,2}.length=size(rearranged_data,2);


cifti_write(new_timeseries, [outfolder '/sub-' SUB '_ses-' SES '_task-' TASK '_bold_shuffled_timeseries.dtseries.nii']);
%% step 3, load motion file and create masks
%load motion file

%% step 3.1, sort motion file according to new run order

%split data by run according to the frames per run
for i=1:size(framelist_start,1)
    fd_by_run{i}=retained_frames(framelist_start(i):framelist_stop(i));
end
fd_by_run{i+1}=retained_frames(framelist_stop(i)+1:end);

%rearrange data by run order to build new concatenated motion trace
k=1;
rearranged_fd=[fd_by_run{1,random_order(k)}];
while k<size(framelist_stop,1)
rearranged_fd=[rearranged_fd; fd_by_run{1,random_order(k+1)}];
k=k+1;
end
rearranged_fd=[rearranged_fd; fd_by_run{1,end}];

%% step 3.2 replace cell in motion file
motion_data{1,index}.frame_removal=abs(rearranged_fd-1);
motion_data{1,index}.total_frame_count=size(rearranged_fd,1);
motion_data{1,index}.remaining_frame_count=size(full_framelist,1);
motion_data{1,index}.remaining_seconds=size(full_framelist,1)*TR;
save([outfolder '/sub-' SUB '_ses-' SES '_task-' TASK '_desc-filtered_motion_mask.mat'], 'motion_data');

%% step 3.3, create masks and write them to tmp space
mkdir([outfolder '/masks'])

%mask half 1 for every minute defined in MIN_X
MIN_X=[1:MAXMIN];

for i=1:size(MIN_X,2)
    framecount=round(MIN_X(i)*60/TR);
    mask_h1=zeros(size(rearranged_fd));
    mask_h1(full_framelist(1:framecount))=1;

    writematrix(mask_h1, [outfolder '/masks/sub-' SUB '_ses-' SES '_mask_half1_' num2str(MIN_X(i)) 'min.txt']);
end

%mask half 2
cap=round(MAXMIN*60/TR); % min for half 1

if size(full_framelist,1)>cap*2
    for i=1:size(MIN_X,2)
        framecount=round(MIN_X(i)*60/TR);
        mask_h2=zeros(size(rearranged_fd));
        mask_h2(full_framelist(cap+1:cap+framecount))=1;
        writematrix(mask_h2, [outfolder '/masks/sub-' SUB '_ses-' SES '_mask_half2_' num2str(MIN_X(i)) 'min.txt']);
    end
else
    error('not enough data')
end
end

