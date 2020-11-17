function drawHeatmap(source, target, heatmap_title)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% source, target are RGB or double

if ~isa(source, 'double')
    source = im2double(source);
end

if ~isa(target, 'double')
    target = im2double(target);
end
absdiff = imabsdiff(source, target);
% absdiff: NxNx3
% take mean of three channels R G B
mean3channels = mean(absdiff, 3);
figure;imagesc(mean3channels);
if strlength(heatmap_title) ~= 0
    title(heatmap_title);
end
caxis([0 0.08]);

c = colorbar;
c.Location = 'southoutside';
ax = gca;
axpos = ax.Position;
c.Position(4) = 0.5*c.Position(4);
ax.Position = axpos;

axis off;
set(gca,'LooseInset',get(gca,'TightInset'));
end

