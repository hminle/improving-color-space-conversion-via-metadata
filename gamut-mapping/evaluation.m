clc
clear
warning off

experiment_name = 'sRGB2ProPhoto_Global';
target_colorspace = 'ProPhoto RGB'; %ProPhoto RGB | P3 | sRGB
in_dir = '../From_sRGB_to_ProPhoto_Global';
target_dir = '../ProPhoto';
in_ext = '.tif';
target_ext = '.tif';

in_images = dir(fullfile(in_dir,['*' in_ext]));
in_images = fullfile(in_dir,{in_images(:).name});
target_images = dir(fullfile(target_dir,['*' target_ext]));
target_images = fullfile(target_dir,{target_images(:).name});

if strcmpi(target_colorspace,'prophoto rgb')
    deltaE2000 = [];
end
PSNR = [];
MAE = [];

for i = 1 : length(in_images)
    fprintf('Processing (%d/%d) ... \n',i,length(in_images));
    
    in_img = im2double(imread(in_images{i}));
    target_img = im2double(imread(target_images{i}));
    
    %% Evaluation
    if strcmpi(target_colorspace,'prophoto rgb')
    % deltaE
    deltaE2000 = [deltaE2000; ...
        calc_deltaE2000(in_img, target_img, target_colorspace)];
    end
    %% Calculate MSE MAE
    PSNR = [PSNR; psnr(in_img, target_img)];
    MAE = [MAE; calc_mae(in_img, target_img)];
end

if strcmpi(target_colorspace,'prophoto rgb')
    fprintf(...
        'DeltaE 2000:\n mean: %0.2f, median: %0.2f, Q1: %0.2f, Q3: %0.2f\n',...
        mean(deltaE2000), median(deltaE2000), quantile(deltaE2000,0.25), ...
        quantile(deltaE2000,0.75));
end

fprintf('PSNR:\n mean: %0.2f, median: %0.2f, Q1: %0.2f, Q3: %0.2f\n',...
    mean(PSNR), median(PSNR), quantile(PSNR,0.25), quantile(PSNR,0.75));

fprintf('MAE:\n mean: %0.2f, median: %0.2f, Q1: %0.2f, Q3: %0.2f\n',...
    mean(MAE), median(MAE), quantile(MAE,0.25), quantile(MAE,0.75));

if strcmpi(target_colorspace,'prophoto rgb')
    results.deltaE2000 = deltaE2000;
end
results.PSNR = PSNR;
results.MAE = MAE;

save(experiment_name,'results','-v7.3');
