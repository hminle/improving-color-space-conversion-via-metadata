function M = computeMapping(source, target)
%source: txtx3 image
%target: txtx3 image

source_reshaped = reshape(source,[],3);
target_reshaped = reshape(target,[],3);

M = kernel(source_reshaped)\target_reshaped;

end

