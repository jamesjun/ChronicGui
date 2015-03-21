function cSFet = getFet1(vcFullpath, P)        
[~,vcDate,~] = fileparts(vcFullpath);
vcDate = vcDate(1:13);

[cmData, Sfile] = importWhisper(vcFullpath, P);
P.vcDate = vcDate;
P.sRateHz = Sfile.sRateHz;
cSFet = detectPeaks(cmData(P.viShank), P);
end %getFet1