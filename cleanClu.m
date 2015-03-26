function viClu = cleanClu(trWav, viClu, P)
% clean the clusters based on minimum channel outliers
if ~isfield(P, 'spkLim'), P.spkLim = [-8, 12]; end
if ~isfield(P, 'maxChanDiff'), P.maxChanDiff = 2; end

iCluNoise = 1;
nClu = max(viClu);
nChans = size(trWav, 2);
imin = -P.spkLim(1)+1;
for iClu = 2:nClu
    viSpk = find(viClu == iClu);
    mrWav = reshape(trWav(imin, :, viSpk), [nChans, numel(viSpk)]);
    [~, viMinChan] = min(mrWav);
%     iMinChan = median(viMinChan);
    viNoise = viSpk(abs(viMinChan-median(viMinChan)) > P.maxChanDiff);
    viClu(viNoise) = iCluNoise;
    if ~isempty(viNoise)
        fprintf('iClu:%d, %d noisy spikes removed\n', iClu, numel(viNoise));
    end
end