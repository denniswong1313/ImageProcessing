clear all
clc
%% IMAGE INPUT
filename = '2-1.tif';
XRes = 60;
YRes = 60;
ZRes = 1;
inputfile = zeros(XRes, YRes, ZRes);
for i = 1:ZRes
    inputfile(:,:,i) = imread(filename, i);
end

%% PROCESSING PARAMETERS
Gain1X = 1; % This is the scaling factor by which the new image will be sized
Gain1Y = 1;
Gain1Z = 1;

xySensor = 1.6;
zSensor = 6;

HRX1 = Gain1X * XRes;
HRY1 = Gain1Y * YRes; 
HRZ1 = Gain1Z * ZRes;

img_scale = resize2D(inputfile, HRX1, HRY1);

%% GENERATE PSF
psf = CSgausfilt3D(4.3, 18, Gain1X); % This is actually only a 2D PSF

psf = double(psf);
psf = psf ./ sum(sum(sum(psf)));

imwrite(psf,'PSFtest.tif');

A = convmtx2(psf,HRX1,HRY1);
A = transpose(A);
        
    
%% RUN OPTIMIZATION
target = img_scale;
At = transpose(A);
lambda = find_lambdamax_l1_ls_nonneg(At,target(:));
% lambda = ;
[img_est, status] = l1_ls_nonneg(A, target(:), 0.7*lambda, 0.01);
img_est = reshape(img_est, [(size(img_scale,1)+size(psf,1)-1) (size(img_scale,2)+size(psf,2)-1)]);
% img_est = reshape(img_est, [sqrt(size(img_est,1)) sqrt(size(img_est,1))]);
output = uint16(img_est.*(65536/max(img_est(:))));
imwrite(output,'res_test_roi1_experimental_pre.tif');
imwrite(img_est,'res_test_roi1_experimental_prenosc.tif');

%% CREATE INTERPOLATED GRID
% img_scale = resize2D(output, 6, 6);
Gain2X = 6;
Gain2Y = 6;
Gain2Z = 1;

HRX2 = Gain2X * HRX1;
HRY2 = Gain2Y * HRY1; 
HRZ2 = Gain2Z * HRZ1;

img_scale_nosc = resize2D(img_est, HRX2, HRY2);


img_scale = uint16(img_scale_nosc.*(65536/max(img_scale_nosc(:))));

imwrite(img_scale,'res_test_roi1_experimental1_2stg.tif');
% imwrite(img_scale_nosc,'res_test_roi1_experimental1_nosc.tif');


   

