function tr = detrendTr(tr)

for iSpk = 1:size(tr,3)
    tr(:,:,iSpk) = detrend(tr(:,:,iSpk));
end