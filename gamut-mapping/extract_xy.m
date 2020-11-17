% ===================================================
% *** FUNCTION extract RGB in xy 
% *** color_space can be 'sRGB', 'ProPhoto'

function [rgb_xy, wp_xy, rgb_xy_lines] = extract_xy(color_space)

icc_folder = iccroot;
profiles = iccfind(icc_folder, color_space);
profile = profiles{1};

% Get RGB XYZ values
rXYZ = profile.MatTRC.RedColorant;
gXYZ = profile.MatTRC.GreenColorant;
bXYZ = profile.MatTRC.BlueColorant;
wpXYZ = profile.MediaWhitePoint;
% create a 3x3 matrix of XYZ values of RGB
rgbXYZ = [rXYZ; gXYZ; bXYZ];

% Convert XYZ 2 xy
cform_xyz2xyl = makecform('xyz2xyl');
xyl = applycform(rgbXYZ, cform_xyz2xyl);
wp_xyl = applycform (wpXYZ, cform_xyz2xyl);

% size(xyl) = 3x3
% column 3 is Y --> we remove it
rgb_xy = [xyl(:, 1), xyl(:, 2)];

% WhitePoint xy
wp_xy = [wp_xyl(:,1), wp_xyl(:,2)];

% rgb_xy_lines for drawing color space gamut lines on chromaticity diagram
rgb_xy_lines = [rgb_xy; rgb_xy(1, :)];

end