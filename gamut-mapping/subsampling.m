function output = subsampling (I, t)
inds_1 = round(linspace(1,size(I,1),t));
inds_2 = round(linspace(1,size(I,2),t));
output = I(inds_1,inds_2,:);

