clear all
close all
clc

%% From offline phantom study (Please see the workflow)
V_ref_0 = 210;           %The ref voltage (V) adjusted by the scanner during the offline phantom study
P_WCPS_0 = 3.74;         %The input power (W) reported in the log file corresponding to the worst-case pulse sequence 

%% The T1w DICOM file MUST be 3D with isotropic resolution
[file,path] = uigetfile('*.dcm','Please select the 3D T1w DICOM file');
DICOMinfo = dicominfo([path,file]);
DICOM = dicomread([path,file]);

% res = double(DICOMinfo.Unknown_0018_1320 * 1e-3);                                                                    %Isotropic Resolution (m) --> Matlab 2019
res = double(DICOMinfo.PerFrameFunctionalGroupsSequence.Item_1.PixelMeasuresSequence.Item_1.PixelSpacing(1) * 1e-3);   %Isotropic Resolution (m) --> Matlab 2024

T1 = permute(DICOM,[1,2,4,3]);      %T1w 3D matrix
Mosaic = MosaicGen(T1);
figure('units','normalized','outerposition',[0 0 1 1])
imagesc(Mosaic); colormap jet, axis equal, axis off
clc
Sgtl_chk = input('Is this a sagittal view? Please enter y or n: ', 's');
if Sgtl_chk == "n"
    T1 = permute(DICOM,[1,4,2,3]);
    Mosaic = MosaicGen(T1);
    figure(1)
    imagesc(Mosaic); colormap jet, axis equal, axis off
    clc
    Sgtl_chk = input('Is this a sagittal view? Please enter y or n: ', 's');
end
if Sgtl_chk == "n"
    T1 = permute(DICOM,[2,4,1,3]);
    Mosaic = MosaicGen(T1);
    figure(1)
    imagesc(Mosaic); colormap jet, axis equal, axis off
    clc
    Sgtl_chk = input('Is this a sagittal view? Please enter y or n: ', 's');
end
if Sgtl_chk == "n"
    clc
    disp('Please check the T1w DICOM and make sure it is acquired with a 3D sequence')
    return
end

%% Creating mask and threshold
f2 = figure(2);
h = histogram(T1);
BE = h.BinEdges;
V = h.Values;
[pks, locs] = findpeaks(V.');
[temp,ind] = sort(pks);
[~,q] = min(V(1:locs(ind(end-1))));
Threshold = BE(q);
Mask = zeros(size(T1,1),size(T1,2),size(T1,3));
Mask(T1>=Threshold) = 1;
Mask = logical(Mask);
MosaicMask = MosaicGen(Mask(:,:,round(end/4):round(end/20):end-round(end/4)));
close(f2)
figure('units','normalized','outerposition',[0 0 1 1])
f2 = figure(2);
imagesc(MosaicMask); colormap gray, axis equal, axis off
clc
Mask_chk = input('Is this reasonably masking the background noise while preserving the tissue? Please enter y or n: ', 's');

if Mask_chk == "n"
    close(f2)
    figure(2)
    plot(V)
    ylim([0 0.1*max(V)])
    clc
    disp('Please select the mid point of the little bump on Figure 2')
    [x, ~] = ginput(1);
    [~,q] = min(V(1:round(x)));
    Threshold = BE(q);

    Mask = zeros(size(T1,1),size(T1,2),size(T1,3));
    Mask(T1>=Threshold) = 1;
    Mask = logical(Mask);
end
figure(3)
imagesc(squeeze(T1(:,:,round(size(T1,3)/2)))); colormap gray, axis equal, axis off
clc
disp('Please select an ROI containing the head and neck on Figure 3')
ROI = roipoly;
ROI = repmat(reshape(ROI,[size(T1,1) size(T1,2)]),[1 1 size(T1,3)]);

%% Output for the in-vivo scan
dBLoss_Cable = 1;                                                          %Cable Loss of the Nova Coil (1Tx)
w = sum(Mask(ROI)) * (res)^3 * 1080;                                       %1080kg/m3: average mass density
P_max = 3.2 * w * db2pow(dBLoss_Cable);                         %Maximum allowed power compliant with normal mode 6 min SAR
    
V_ref_max = V_ref_0 * sqrt(P_max / P_WCPS_0);                              %Maximum allowed reference voltage compliant with SAR limits
clc
disp(['The HEAD WEIGHT is estimated to be ',num2str(round(w*100)/100),' kg'])
disp('---------------------------------------------------------------------------------------')
disp(['The POWER reported in the log file should not exceed ',num2str(round(P_max*10)/10),' W'])
disp('---------------------------------------------------------------------------------------')
disp(['The REFERENCE VOLTAGE on the scanner should not exceed ',num2str(round(V_ref_max)),' V'])
disp('---------------------------------------------------------------------------------------')

%% Save
save T1w.mat Mask res T1 Threshold w P_max V_ref_max ROI -v7.3

%% Utility Function
function Mosaic = MosaicGen(Matrix)    % Input to this function should be a 3D matrix

kk = 0;
xsize = size(Matrix,1);   ysize = size(Matrix,2);   zsize = size(Matrix,3);
Mosaic = zeros(xsize*ceil(sqrt(zsize)) , ysize*ceil(sqrt(zsize)));
for ii = 1:ceil(sqrt(zsize))
    for jj = 1:ceil(sqrt(zsize))
        kk = kk + 1;
        if kk <= zsize
        Mosaic( ((ii-1)*xsize+1):ii*xsize , ((jj-1)*ysize+1):jj*ysize ) = Matrix(:,:,kk);
        end
    end
end

end








