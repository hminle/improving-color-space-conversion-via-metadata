function output = applyMapping(I, M, mask)
if nargin == 2
    mask = [];
end
sz = size(I);
I = reshape(I,[],3);
if isempty(mask) == 0
    mask = reshape(mask,[],1);
    output = I;
    output(mask,:) = kernel(I(mask,:)) * M;
else
output = kernel(I) * M;
output = reshape(output,[sz(1) sz(2) sz(3)]);
end

