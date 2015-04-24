function tr = trFilter(tr, vrFilt)
if numel(size(tr)) == 3
    for iChan=1:size(tr,2)
        tr(:,iChan,:) = filter(vrFilt,1,tr2mr(tr,iChan));        
    end
else
    tr = filter(vrFilt,1,tr);
end