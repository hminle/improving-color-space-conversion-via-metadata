function O=kernel(I)
% kernel(R,G,B)=[R,G,B,RG,RB,GB,R2,G2,B2,RGB,1];
% Kernel func reference:
% Hong, et al., "A study of digital camera colorimetric
% characterization based on polynomial modeling." Color
% Research & Application, 2001.
O=[I,... %r,g,b
    I(:,1).*I(:,2),I(:,1).*I(:,3),I(:,2).*I(:,3),... %rg,rb,gb
    I.*I,... %r2,g2,b2
    I(:,1).*I(:,2).*I(:,3),... %rgb
    ones(size(I,1),1)]; %1
end