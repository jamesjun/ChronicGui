function [viClu, trWav] = cleanClu(trWav, viClu, P)
% clean the clusters based on minimum channel outliers
if ~isfield(P, 'spkLim'), P.spkLim = [-8, 12]; end
if ~isfield(P, 'maxChanDiff'), P.maxChanDiff = []; end

iCluNoise = 1;
nClu = max(viClu);
nChans = size(trWav, 2);
nWav = size(trWav, 1);
imin = -P.spkLim(1)+1;
viRange0 = (1:nWav)-imin-1;
for iClu = 2:nClu
    viSpk = find(viClu == iClu);
    nSpk = numel(viSpk);
    mrWav = reshape(trWav(imin, :, viSpk), [nChans, nSpk]);
    [~, viMinChan] = min(mrWav);
    iMinChan = median(viMinChan);
    if isempty(P.maxChanDiff)
        viSpk1 = viSpk(viMinChan ~= iMinChan);
        for iSpk1 = 1:numel(viSpk1)
            iSpk = viSpk1(iSpk1);
            [~,imin1] = min(trWav(:, iMinChan, iSpk));
            viRange = mod(viRange0 + imin1, nWav)+1;
            trWav(:, :, iSpk) = trWav(viRange, :, iSpk);
        end
        if ~isempty(viSpk1)
            fprintf('iClu:%d, %d spikes shifted\n', iClu, numel(viSpk1));
        end
    else
        viNoise = viSpk(abs(viMinChan-median(viMinChan)) > P.maxChanDiff);
        viClu(viNoise) = iCluNoise;
        if ~isempty(viNoise)
            fprintf('iClu:%d, %d noisy spikes removed\n', iClu, numel(viNoise));
        end
    end
end