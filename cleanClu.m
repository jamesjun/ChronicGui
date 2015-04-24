function [trWav, Sclu] = cleanClu(trWav, Sclu, varargin)
P = funcDefStr(funcInStr(varargin{:}), ...
    'spkLim', [-8 12], 'nPadding', 0, ...
    'maxChanDiff', [], 'spkRemoveZscore', [], 'vcPeak', 'min', ...
    'iCluNoise', 1, 'viChan', []);

if isstruct(Sclu)
    viClu = Sclu.cl;
    nClu = Sclu.nClu;
else
    viClu = Sclu;
    nClu = max(viClu);
end
nChans = size(trWav, 2);
nWav = size(trWav, 1);
if isempty(P.viChan)
    P.viChan = 1:nChans; 
end
imin = -P.spkLim(1)+P.nPadding+1;
imin0 = imin - P.nPadding;
viRange0 = (1:nWav)-imin-1; %-1 is for mod
viRangeMin = (P.nPadding+1):(nWav-P.nPadding); %minimum search range excluding padding
viChanMin = zeros(1, nClu);
if P.iCluNoise == 0
    iCluStart = 1;
else
    iCluStart = 2;
end
Sclu.vrCluErr = nan(1, nClu);
for iClu = iCluStart:nClu
    viSpk = find(viClu == iClu);
    nSpk = numel(viSpk);
    mrWav1 = reshape(trWav(imin, P.viChan, viSpk), [numel(P.viChan), nSpk]);
    [~, viChanMin1] = min(mrWav1); %find min chan
    iChanMin1 = round(median(viChanMin1));
    viChanMin(iClu) = P.viChan(iChanMin1);
    if isempty(P.maxChanDiff) || isinf(P.maxChanDiff)
        viSpk1 = viSpk(viChanMin1 ~= iChanMin1);
        nShift = 0;
        for iSpk1 = 1:numel(viSpk1)
            iSpk = viSpk1(iSpk1);
            [~,imin1] = min(trWav(viRangeMin, P.viChan(iChanMin1), iSpk)); %find min val
            if imin1 ~= imin0 %compare min time
                viRange = mod(viRange0 + imin1 + P.nPadding, nWav)+1;
                trWav(:, :, iSpk) = trWav(viRange, :, iSpk);
                nShift = nShift+1;
            end
        end
        if nShift > 0
            fprintf('iClu:%d, %d/%d spikes shifted\n', ...
                iClu, nShift, nSpk);
        end
    else
        viNoise1 = abs(viChanMin1-median(viMinChan)) > P.maxChanDiff;
        viClu(viSpk(viNoise1)) = P.iCluNoise;
        viSpk(viNoise1) = [];
        if ~isempty(viNoise1)
            fprintf('iClu:%d, %d/%d spikes removed\n', ...
                iClu, numel(viNoise1), numel(viSpk));
        end
    end
    
    %do it for all chan
    if ~isempty(P.spkRemoveZscore) %remove based on minimum channel only
        mrWav = reshape(trWav(viRangeMin, iChanMin1, viSpk), ...
            [numel(viRangeMin), numel(viSpk)]);
        mrWavDiff = bsxfun(@minus, mrWav, median(mrWav, 2));
        vrErr = std(mrWavDiff);
        viNoise1 = find(zscore(vrErr) > P.spkRemoveZscore);
        viClu(viSpk(viNoise1)) = P.iCluNoise;
        viSpk(viNoise1) = [];
        vrErr(viNoise1) = [];
        Sclu.vrCluErr(iClu) = mean(vrErr);
        if ~isempty(viNoise1)
            fprintf('iClu:%d, %d/%d spikes removed\n', ...
                iClu, numel(viNoise1), numel(viSpk));
%             figure; hist(vrErrZ);
%             title(sprintf('iClu:%d, %d/%d spikes removed\n', ...
%                 iClu, numel(viNoise1), numel(viSpk)));
        end        
    end
end

Sclu.viChanMin = viChanMin;
Sclu.cl = viClu;