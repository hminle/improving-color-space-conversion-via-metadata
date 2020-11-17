clc
clear
warning off

experiment_name = 'Global_ProPhoto';
in_dir = 'C:\Users\Afifi\OneDrive - York University\sRGB_from_DNG';
target_dir = 'C:\Users\Afifi\OneDrive - York University\ProPhoto_from_DNG';
in_ext = '.jpg';
target_ext = '.tif';
if strcmpi(target_ext,'.tif')
    target_colorSpace = 'ProPhoto RGB';
elseif strcmpi (target_ext, '.jpg')
    target_colorSpace = 'sRGB';
end
in_images = dir(fullfile(in_dir,['*' in_ext]));
in_images = fullfile(in_dir,{in_images(:).name});
target_images = dir(fullfile(target_dir,['*' target_ext]));
target_images = fullfile(target_dir,{target_images(:).name});

deltaE2000 = [];
deltaE = [];
PSNR = [];
MAE = [];

for i = 1 : length(in_images)
    fprintf('Processing (%d/%d) ... \n',i,length(in_images));
    
    in_img = im2double(imread(in_images{i}));
    target_img = im2double(imread(target_images{i}));
    %% Perform Global Mapping
    % Subsmpaling
    sub_sample_size = 150;
    sub_in_img = subsampling(in_img, sub_sample_size);
    sub_target_img = subsampling(target_img, sub_sample_size);
    % Compute mapping on subsamples
    M = computeMapping(sub_in_img, sub_target_img);
    reconstructed = applyMapping(in_img, M);
    % Clipping
    reconstructed(reconstructed > 1) = 1;
    reconstructed(reconstructed < 0) = 0;
    %% Evaluation
    % deltaE
    deltaE2000 = [deltaE2000; ...
        calc_deltaE2000(reconstructed, target_img, target_colorSpace)];
    deltaE = [deltaE;...
        calc_deltaE(reconstructed, target_img, target_colorSpace)];
    %% Calculate MSE MAE
    PSNR = [PSNR; psnr(reconstructed, target_img)];
    MAE = [MAE; calc_mae(reconstructed, target_img)];
end


fprintf('DeltaE 2000:\n mean: %0.3f, median: %0.3f, Q1: %0.3f, Q3: %0.3f\n',...
    mean(deltaE2000), median(deltaE2000), quantile(deltaE2000,0.25), ...
    quantile(deltaE2000,0.75));


fprintf('DeltaE 76:\n mean: %0.3f, median: %0.3f, Q1: %0.3f, Q3: %0.3f\n',...
    mean(deltaE), median(deltaE), quantile(deltaE,0.25), ...
    quantile(deltaE,0.75));


fprintf('PSNR:\n mean: %0.3f, median: %0.3f, Q1: %0.3f, Q3: %0.3f\n',...
    mean(PSNR), median(PSNR), quantile(PSNR,0.25), quantile(PSNR,0.75));

fprintf('MAE:\n mean: %0.3f, median: %0.3f, Q1: %0.3f, Q3: %0.3f\n',...
    mean(MAE), median(MAE), quantile(MAE,0.25), quantile(MAE,0.75));

% 
results.deltaE2000 = deltaE2000;
results.deltaE = deltaE;
results.PSNR = PSNR;
results.MAE = MAE;

save(experiment_name,'results','-v7.3');
