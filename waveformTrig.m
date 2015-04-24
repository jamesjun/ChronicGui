function [trSpkWav, viSpk, viKill] = waveformTrig(mrWav, viSpk, timeLim)
nSpks = numel(viSpk);
nChans = size(mrWav,2);
nSamples = size(mrWav,1);
viRange0 = timeLim(1):timeLim(2);

trSpkWav = zeros([numel(viRange0), nChans, nSpks], 'like', mrWav);

viKill = [];
for iSpk = 1:nSpks
    viRange = viRange0 + viSpk(iSpk);
    if viRange(1) < 1, viKill(end+1) = iSpk; continue; end
    if viRange(end) > nSamples, viKill(end+1) = iSpk; continue; end
    trSpkWav(:,:,iSpk) = mrWav(viRange,:);
end

trSpkWav(:,:,viKill) = [];
viSpk(viKill) = [];