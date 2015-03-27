function vcDate = getDateFromFullpath(vcFullpath)

try
    [~,vcDate,~] = fileparts(vcFullpath);
    vcDate = vcDate(1:13);
catch err
    S = dir(vcFullpath);
    vcDate = S.date;
    vcDate = datestr(datenum(vcDate), 21);
end