function [output_RGB] = convertLab2RGB(source,color_space)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
if ~isa(source, 'double')
    source = im2double(source);
end
icc_folder = iccroot;

% Find color profile
profiles = iccfind(icc_folder, color_space);
profile = profiles{1};

cform = makecform('lab2xyz');
output_XYZ = applycform(source, cform);
cform = makecform('mattrc',profile.MatTRC, ...
    'direction','inverse');
output_RGB = applycform(output_XYZ, cform);
end

