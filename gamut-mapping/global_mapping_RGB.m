image_name = "a0088-_DGW6376";
sRGB_filename = image_name + ".jpg";
proPhoto_filename = image_name + ".tif";
pro_PTS_filename = 'a0088-_DGW6376_converted_back_PTS.tif';

srgb_img = imread(sRGB_filename);
proPhoto_img = imread(proPhoto_filename);

sRGB = im2double(srgb_img);
proRGB = im2double(proPhoto_img);

visualize_gamut_of_image(proRGB, 'ProPhoto RGB', ...
    'Original ProPhoto Image CIE diagram');
visualize_gamut_of_image(sRGB, 'sRGB', ...
    'sRGB Image CIE diagram');

%% Perform Global Mapping
% Subsmpaling
sub_sample_size = 150;
sub_sRGB = subsampling(sRGB, sub_sample_size);
sub_pro = subsampling(proRGB, sub_sample_size);

% Compute mapping on subsamples
M = computeMapping(sub_sRGB, sub_pro);
reconstructed_proPhoto_RGB = applyMapping(sRGB, M);
% Clipping
reconstructed_proPhoto_RGB = double(reconstructed_proPhoto_RGB);
reconstructed_proPhoto_RGB(reconstructed_proPhoto_RGB > 1) = 1;
reconstructed_proPhoto_RGB(reconstructed_proPhoto_RGB < 0) = 0;

visualize_gamut_of_image(reconstructed_proPhoto_RGB, 'ProPhoto RGB', ...
    'Reconstructed ProPhoto Image using Global Mapping CIE Diagram');


%% Visualize Photoshop

pro_PTS = imread(pro_PTS_filename);
visualize_gamut_of_image(pro_PTS, 'ProPhoto RGB', ...
    'Reconstructed ProPhoto Using PTS CIE Diagram');


%% Evaluation
% deltaE

deltaE2000_our = calc_deltaE2000(reconstructed_proPhoto_RGB, ...
    proPhoto_img, 'ProPhoto RGB');
deltaE_our = calc_deltaE(reconstructed_proPhoto_RGB, proPhoto_img, ...
    'ProPhoto RGB');

deltaE2000_PTS = calc_deltaE2000(pro_PTS, proPhoto_img, 'ProPhoto RGB');
deltaE_PTS = calc_deltaE(pro_PTS, proPhoto_img, 'ProPhoto RGB');

disp(sprintf('DeltaE2000 - DeltaE Global Mapping: %0.3d - %0.3d', deltaE2000_our, deltaE_our));
disp(sprintf('DeltaE2000 - DeltaE PTS: %0.3d - %0.3d', deltaE2000_PTS, deltaE_PTS));


%% Calculate MSE MAE
mse_our = calc_mse(reconstructed_proPhoto_RGB, proPhoto_img);
mae_our = calc_mae(reconstructed_proPhoto_RGB, proPhoto_img);

mse_PTS = calc_mse(pro_PTS, proPhoto_img);
mae_PTS = calc_mae(pro_PTS, proPhoto_img);


disp(sprintf('MSE - MAE Global Mapping: %0.3d - %0.3d', mse_our, mae_our));
disp(sprintf('MSE - MAE PTS: %0.3d - %0.3d', mse_PTS, mae_PTS));


%% Draw Heatmap
drawHeatmap(reconstructed_proPhoto_RGB, ...
    proPhoto_img, 'Heatmap between Global Mapping and the original');
drawHeatmap(pro_PTS, ...
    proPhoto_img, 'Heatmap between PTS and the original');

%% Saving reconstructed ProPhoto RGB

out_filename = image_name + "_reconstructed_GlobalMappingRGB.tif";

RGB16 = uint16(round(reconstructed_proPhoto_RGB*65535));
imwrite(RGB16, out_filename);

