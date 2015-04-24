function mrFet = fetXcovPair(trSpkWav, varargin)
P = funcDefStr(funcInStr(varargin{:}), ...
    'nLags', 3, 'cvChanPair', [], 'fZscore', 1);

    
nFet = (P.nLags*2+1);
nSpks = size(trSpkWav,3);
nChans = size(trSpkWav,2);
if isempty(P.cvChanPair)
    if nChans < 2, error('fetXcovPair-nChan==1'); end
    P.cvChanPair = cell(1, nChans*2-3);
    P.cvChanPair{1} = [2,1];
    for iChan = 3:nChans
        P.cvChanPair{iChan*2-4} = [iChan, iChan-2];
        P.cvChanPair{iChan*2-3} = [iChan, iChan-1];
    end
end
nPairs = numel(P.cvChanPair);

viRange = 1:nFet;
mrFet = zeros(nFet * nPairs, nSpks);
for iPair = 1:nPairs
    mrFet(viRange, :) = calcXcovPair(trSpkWav, 'viChan', P.cvChanPair{iPair}, 'nLags', P.nLags);
    viRange = viRange + nFet;
end

if P.fZscore
    mrFet = (mrFet - mean(mrFet(:))) ./ std(mrFet(:));
    %mrFet = zscore(mrFet')';
    %mrFet = zscore(mrFet);
end

if nargout == 0
    vr=pdist(mrFet','cosine'); figure; cdfplot(vr);
    disp(median(vr));
end