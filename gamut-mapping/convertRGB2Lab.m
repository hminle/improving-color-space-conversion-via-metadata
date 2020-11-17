function [output_Lab] = convertRGB2Lab(source, color_space)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if ~isa(source, 'double')
    source = im2double(source);
end
icc_folder = iccroot;

% Find color profile
profiles = iccfind(icc_folder, color_space);
profile = profiles{1};
% Convert to XYZ
cform = makecform('mattrc',profile.MatTRC, ...
    'direction','forward');
output_XYZ = applycform(source, cform);
cform = makecform('xyz2lab');
output_Lab = applycform(output_XYZ, cform);
end

