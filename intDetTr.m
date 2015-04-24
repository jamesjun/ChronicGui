function tr = intDetTr(tr)

for iSpk = 1:size(tr,3)
    tr(:,:,iSpk) = detrend(cumsum(tr(:,:,iSpk)));
end