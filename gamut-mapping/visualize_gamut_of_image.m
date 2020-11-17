
function visualize_gamut_of_image(RGB, color_space, diagram_title, sampleStep)

if nargin == 3
    sampleStep = 1; %no sampling
end
RGB = reshape(RGB, [], 3);

if ~isa(RGB, 'double')
    RGB = im2double(RGB);
end

icc_folder = iccroot;
% if strcmp(color_space, 'sRGB')

fprintf('Color Space %s', color_space);

profiles = iccfind(icc_folder, color_space);
profile = profiles{1};
% convert ProPhoto RGB 2 XYZ
cform = makecform('mattrc',profile.MatTRC, ...
    'direction','forward');
XYZ = applycform(RGB, cform);
cform_xyz2xyl = makecform('xyz2xyl');
xyl = applycform(XYZ, cform_xyz2xyl);


disp("xyl")
size(xyl)
xv = xyl(1:sampleStep:end,1);
yv = xyl(1:sampleStep:end,2);


[rgb_xy, wp_xy, rgb_xy_lines] = extract_xy(color_space);
% plotting the CIE 1931 XY Chromaticity diagram 

figure 
plotChromaticity 
hold on % hold on figure, there's more to come 

scatter(xv, yv, 1, 'MarkerFaceColor', 'flat'); 
% Draw gamut border
gamut_border = line(rgb_xy_lines(:,1), rgb_xy_lines(:,2), 'Color', 'red');
legend([gamut_border], {color_space});
title(diagram_title);
hold off;

end