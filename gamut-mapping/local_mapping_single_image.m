clear
clc
close all;
warning off;

%% Read input
tic
image_name = "Canon1DsMkIII_0003";
target_colorspace = 'ProPhoto RGB';
source_filename = image_name + ".jpg";
target_filename = image_name + ".tif";

source = im2double(imread(source_filename));
target = im2double(imread(target_filename));

% Subsampling
sub_sample_size = 150;
sub_source = subsampling(source, sub_sample_size);
sub_target = subsampling(target, sub_sample_size);


%% global 
% Compute mapping on subsamples
M = computeMapping(sub_source, sub_target);
corrected_global = applyMapping(source, M);
% Clipping
reconstructed_global = corrected_global;
reconstructed_global(reconstructed_global > 1) = 1;
reconstructed_global(reconstructed_global < 0) = 0;
sub_corrected_global = applyMapping(sub_source, M);

%% super-pixels
N = 100;
[super_target,N] = superpixels(sub_target,N,'IsInputLab',true);
sub_target = reshape(sub_target,[],3);
sub_corrected_global = reshape(sub_corrected_global,[],3);
se = strel('disk', 15);
Mf = zeros(N,11,3);
%% local post-correction
for s = 1 : N
    mask = super_target == s;
    inds = find(reshape(mask,[],1));
    mask = double(imdilate(mask,se));
    mask = imgaussfilt(mask,8);
    w = reshape(mask,[],1);
    w = w./sum(w);
    m = lscov(kernel(reshape(sub_corrected_global,[],3)),...
        reshape(sub_target,[],3),w);
	Mf(s,:,:) = reshape(m, [11,3]);
end


%% correction
reconstructed = corrected_global;
for s = 1 : N
    mask = super_target == s;
    blend_mask = imresize(mask,[size(corrected_global,1), size(corrected_global,2)]);
    temp = applyMapping(corrected_global, squeeze(Mf(s,:,:)), blend_mask);
	reconstructed(repmat(blend_mask,1,1,3)) = temp(repmat(blend_mask,1,1,3));
end
toc

%% Clipping out of gamut
reconstructed(reconstructed > 1) = 1;
reconstructed(reconstructed < 0) = 0;


%% Evaluation
fprintf('Global: PSNR=%0.3f, MAE=%0.3f, deltaE=%0.3f\n',...
    psnr(reconstructed_global, target), calc_mae(reconstructed_global, target),...
    calc_deltaE2000(reconstructed_global, target, target_colorspace));

fprintf('Ours: PSNR=%0.3f, MAE=%0.3f, deltaE=%0.3f\n',...
    psnr(reconstructed, target), calc_mae(reconstructed, target),...
    calc_deltaE2000(reconstructed, target, target_colorspace));

