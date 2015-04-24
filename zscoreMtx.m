function mr = zscoreMtx(mr)

mr = (mr - nanmean(mr(:))) / nanstd(mr(:));
%mr = zscore(mr')';