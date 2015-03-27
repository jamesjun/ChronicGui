function vrDist = isoDist(mrFet, viClu)

nClu = max(viClu);
nSpk = size(mrFet, 2);
vrDist = nan(nClu, 1);
nFet = size(mrFet, 1);

mrFet = mrFet(:, viClu>1)'; %for mahal, obs x dimm
viClu(viClu==1) = [];

% mrFetOut = mrFet(viClu>1, :);
for iClu=2:nClu
    vlSpkIn = (viClu == iClu);
    nSpkIn = sum(vlSpkIn);
%     nSpkOut = nSpk - nSpkIn;
    if nSpkIn < nFet, continue; end %error
    m = mahal(mrFet, mrFet(vlSpkIn,:));
%     mIn = m(vlSpkIn);
%     mOut = m(~vlSpkIn);
	sOut = sort(m(~vlSpkIn));
    if nSpkIn > numel(sOut), continue; end
	vrDist(iClu) = sOut(nSpkIn);
end