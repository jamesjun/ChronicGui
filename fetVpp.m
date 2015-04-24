function mrFet = fetVpp(tr, varargin)

P = funcDefStr(funcInStr(varargin{:}), 'fZscore', 1);
nChans = size(tr,2);
nSpks = size(tr,3);

mrFet = zeros(nSpks, nChans);
for iChan = 1:nChans
    mr = tr2mr(tr, iChan);
    mrFet(:,iChan) = max(mr)-min(mr);
end
mrFet = mrFet';

if P.fZscore
    mrFet = zscoreMtx(mrFet);
end