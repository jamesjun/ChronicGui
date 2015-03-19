function [cmSpkWav, cvSpkIdx, vrThresh] = detectSpikes(mrWav)
fSubtMean = 1;

nChans = size(mrWav, 2);
cvSpkIdx = cell(1, nChans);
cmSpkWav = cell(1, nChans);
vrThresh = 5 * median(abs(mrWav))/0.6745;  % default methods

if fSubtMean
    mrWav = bsxfun(@minus, mrWav, mean(mrWav, 2)); %subtract shank mean
end

for iChan = 1:nChans
    [cmSpkWav{iChan}, cvSpkIdx{iChan}] = ...
        detectSpikes_SingleChan(mrWav(:, iChan), vrThresh(iChan));
end
