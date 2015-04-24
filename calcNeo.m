function mr = calcNeo(mr)
switch numel(size(mr))
    case 2
        mr = mr(2:end-1,:).^2 - mr(1:end-2,:) .* mr(3:end,:);
        mr = mr([1, 1:end, end],:);
    case 3
        mr = mr(2:end-1,:,:).^2 - mr(1:end-2,:,:) .* mr(3:end,:,:);
        mr = mr([1, 1:end, end],:,:);
end