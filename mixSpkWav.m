function trSpkWav = mixSpkWav(trSpkWav, varargin)
P = funcDefStr(funcInStr(varargin{:}), ...
        'fMix', 0);

nSpks = size(trSpkWav, 3);
nChans = size(trSpkWav, 2);
nChans1 = nChans+1;
.5-.5/(nChans-1)


for iSpk=1:nSpks
    mr = trSpkWav(:,:,iSpk);
    trSpkWav(:,:,iSpk) = bsxfun(@plus, mr/2, sum(mr,2)/2/(nChans-1));
end