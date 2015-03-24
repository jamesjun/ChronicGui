function vcDate = getDateFromFullpath(vcFullpath)

[~,vcDate,~] = fileparts(vcFullpath);
vcDate = vcDate(1:13);