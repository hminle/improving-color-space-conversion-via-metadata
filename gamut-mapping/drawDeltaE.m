function drawHeatmap(deltaE, heatmap_title)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% source, target are RGB or double


figure;imagesc(deltaE);
if strlength(heatmap_title) ~= 0
    title(heatmap_title);
end
caxis([0 15]);

c = colorbar;
c.Location = 'southoutside';
ax = gca;
axpos = ax.Position;
c.Position(4) = 0.5*c.Position(4);
ax.Position = axpos;

axis off;
set(gca,'LooseInset',get(gca,'TightInset'));
end

