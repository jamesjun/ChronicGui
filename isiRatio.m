function vrRat = isiRatio(vrTime, viClu)

nClu = max(viClu);
% nSpk = size(mrFet, 2);
vrRat = nan(nClu, 1);
intLim = [.002, .02];

for iClu=2:nClu
    vlSpkIn = (viClu == iClu);
    vrInt = diff(vrTime(vlSpkIn));
    vrRat(iClu) = sum(vrInt<=intLim(1)) / sum(vrInt<=intLim(2));
end