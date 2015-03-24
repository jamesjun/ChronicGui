function vrDist = isoDist(mrFet, viClu)

nClu = max(viClu);
nSpk = size(mrFet, 2);
vrDist = nan(nClu, 1);
nFet = size(mrFet, 1);

mrFet = mrFet'; %for mahal, obs x dimm

for iClu=2:nClu
    vlSpkIn = (viClu == iClu);
    nSpkIn = sum(vlSpkIn);
%     nSpkOut = nSpk - nSpkIn;
    if nSpkIn < nFet, continue; end %error
    m = mahal(mrFet, mrFet(vlSpkIn,:));
%     mIn = m(vlSpkIn);
%     mOut = m(~vlSpkIn);
	sOut = sort(m(~vlSpkIn));
	vrDist(iClu) = sOut(nSpkIn);
end