function mr = tr2mr(tr, ich)

if nargin<2
    mr = reshape(tr, size(tr,1)*size(tr,2), []);
else
    mr = reshape(permute(tr(:,ich,:), [1 3 2]), size(tr,1),[]);
end