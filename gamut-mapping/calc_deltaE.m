%% Calculate Delta E76 between source and target images.
%
% Copyright (c) 2018-present, Mahmoud Afifi
% York University, Canada
% mafifi@eecs.yorku.ca | m.3afifi@gmail.com
%
% This source code is licensed under the license found in the
% LICENSE file in the root directory of this source tree.
% All rights reserved.
%
% Please cite the following work if this program is used:
% Mahmoud Afifi, Brian Price, Scott Cohen, and Michael S. Brown, 
% "When color constancy goes wrong: Correcting improperly white-balanced 
% images", CVPR 2019.
%
% Input:
%   -source: image A
%   -target: image B 
%   -color_chart_area: If there is a color chart in the image (that is
%   masked out from both images, this variable represents the number of
%   pixels of the color chart.
%
% Output:
%   -deltaE: the value of Delta E76 between image A and image B.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 

function deltaE=calc_deltaE(source,target, color_space)

if ~isa(source, 'double')
    source = im2double(source);
end

if ~isa(target, 'double')
    target = im2double(target);
end

if (strcmp(color_space, 'sRGB'))
    source = rgb2lab(source);
    target = rgb2lab(target);
elseif (strcmp(color_space, 'Adobe RGB'))
    source = rgb2lab(source, 'ColorSpace','adobe-rgb-1998');
    target = rgb2lab(target, 'ColorSpace','adobe-rgb-1998');
elseif (strcmp(color_space, 'Display P3'))
    profile = iccread('D:\colorprofiles\Display P3.icc');
    cform = makecform('mattrc',profile.MatTRC, ...
        'direction','forward');
    source = applycform(source, cform);
    target = applycform(target, cform);
    source = xyz2lab(source);
    target = xyz2lab(target);
elseif (strcmp(color_space, 'ProPhoto RGB'))
    icc_folder = iccroot;
    profiles = iccfind(icc_folder, color_space);
    pro_profile = profiles{1};
    cform = makecform('mattrc',pro_profile.MatTRC, ...
        'direction','forward');
    source = applycform(source, cform);
    target = applycform(target, cform);
    source = xyz2lab(source);
    target = xyz2lab(target);
    
    
else
    disp('Unknow Color Space'); return;
end
source = reshape(source,[],3); %l,a,b
target = reshape(target,[],3); %l,a,b
deltaE = sqrt(sum((source - target).^2,2));
deltaE=sum(deltaE)/(size(deltaE,1));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% References:
% [1] http://zschuessler.github.io/DeltaE/learn/