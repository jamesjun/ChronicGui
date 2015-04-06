function mrFet = getFeatures(trSpkWav, P)
% trSpkWav: nTime x nChan x nTran
%   P: {nPadding, spkLim}

% remove padding
if P.nPadding > 0
    trSpkWav = trSpkWav((1+P.nPadding):(end-P.nPadding),:,:);
else
    trSpkWav = trSpkWav;
end
iPeak = -P.spkLim(1)+1;
nSamples = size(trSpkWav, 1);
nChans = size(trSpkWav, 2);
nSpks = size(trSpkWav, 3);
viRange = 1:nSamples;
if P.nInterp > 1
    viRangeInt0 = 1:(1/P.nInterp):nSamples;
else
    viRangeInt0 = [];
end

if P.vcFet(1) == '@'
    eval(sprintf('funcFet = %s;', lower(P.vcFet)));
    mrFet = zeros(nChans, nSpks, 'single');
else
    switch lower(P.vcFet)
        case {'pairvpp', 'paircov', 'paricorr'}
            mrFet = pairFet(S.trSpkWav, P);
            return;
        case 'pca'                            
            mrFet = getWavPca(S.trSpkWav, 3);
            return;
        case 'vpeak'
            mrFet = reshape(trSpkWav(iPeak,:,:), [nChans, nSpks]);
            return
        otherwise
            error('unsupported vcFet: %s', P.vcFet);
    end
end

for iSpk = 1:nSpks
    mrData1 = trSpkWav(:,:,iSpk);
    if ~isempty(viRangeInt0)
        mrData1 = interp1(viRange, mrData1, ...
            viRangeInt0 , 'spline');
    end
    mrFet(:,iSpk) = funcFet(mrData1);    
end