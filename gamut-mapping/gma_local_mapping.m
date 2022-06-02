clear
clc
close all;
warning off;

%% Read input
in_dir = 'D:\Dataset\gamut_mapping_data\WideGamutDataset\test-srgb-8bpc';
target_dir = 'D:\Dataset\gamut_mapping_data\WideGamutDataset\test-prop-8bpc';
out_dir = 'D:\Dataset\gamut_mapping_data\WideGamutDataset\cic2020_local';
in_ext = '.png';
target_ext = '.png';
in_images = dir(fullfile(in_dir,['*' in_ext]));
in_images = fullfile(in_dir,{in_images(:).name});
target_images = dir(fullfile(target_dir,['*' target_ext]));
target_images = fullfile(target_dir,{target_images(:).name});

for i = 1 : length(in_images)
    fprintf('Processing (%d/%d) ... \n',i,length(in_images));
    [~,name,ext] = fileparts(in_images{i});
    source_filename = in_images{i};
    target_filename = target_images{i};
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
    [super_target,N] = superpixels(sub_target,N, 'IsInputLab', true);
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
    
    %% Clipping out of gamut
    reconstructed(reconstructed > 1) = 1;
    reconstructed(reconstructed < 0) = 0;
    
    if strcmpi(target_ext,'.tif') == 1 || strcmpi(target_ext,'.png') == 1
        imwrite(im2uint8(reconstructed),fullfile(out_dir,[name target_ext]));
    else
        imwrite(reconstructed,fullfile(out_dir,[name target_ext]));
    end
end

