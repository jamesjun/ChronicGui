function [S, P] = buildSpikeTable(mrData, varargin)
% per each channels
P = funcDefStr(funcInStr(varargin{:}), ...
    'sRateHz', 25000, 'thresh', [], 'spkLim', [-8, 12], ...
    'nPadding', 0, 'fDiffPair', 0, 'tConvolve', .0005, ...
    'tRefrac', 0, 'fMeasureEvent', 1, 'tLoaded', [], 'sRateHz', [], ...
    'vcPeak', 'vpp', 'nInterp', 4, 'vcFet', 'vpp', 'fCluster', 1);
if nargout == 0, P.fPlot = 1; end

if P.fDiffPair
    [mrData, viChanPair1, viChanPair2] = diffPair(mrData);
else
    viChanPair1 = [];
    viChanPair2 = [];
end
nChans = size(mrData, 2);
spkLim1 = P.spkLim + [-1, 1] * P.nPadding;

vrThreshW = []; %week threshold
if isempty(P.thresh)
    vrThresh = 5 * median(abs(mrData))/0.6745;  % default methods
else
    if numel(P.thresh) == 1
        vrThresh = repmat(P.thresh, [1, nChans]);
    elseif numel(P.thresh) == 2
        vrThresh = std(mrData) * max(P.thresh);  % default methods
        vrThreshW = std(mrData) * min(P.thresh);
    end
end

%generate transition markers
if ~isempty(vrThreshW) 
    %do not convolve vlData for dual threshold scheme
    mlData = bsxfun(@lt, mrData, -vrThreshW)'; %widen the mask
    vlData = logical(any(mlData));
    
    % convolve vlData for merging purpose
    vlData = logical(conv(double(vlData), ...
        ones(round(P.tConvolve * P.sRateHz),1), 'same'));
    
    vlDataS = logical(any(bsxfun(@lt, mrData, -vrThresh)'));
    [viUp, viDn, nTran] = findTrans(vlData);
    for iTran=1:nTran
        %kill transitions that doesn't contain supra strong threshold
        viRange = viUp(iTran):viDn(iTran);
        if ~any(vlDataS(viRange))
            vlData(viRange) = 0;
            viUp(iTran) = nan;
%             viDn(iTran) = nan;
        end
    end    
    vlKill = isnan(viUp);
    viUp(vlKill) = [];
    viDn(vlKill) = [];
    nTran = numel(viUp);
else
    %single threshold scheme. convolve threshold data
    mlData = bsxfun(@lt, mrData, -vrThresh)';
    vlData = logical(conv(double(any(mlData)), ...
        ones(round(P.tConvolve * P.sRateHz),1), 'same'));
    [viUp, viDn, nTran] = findTrans(vlData);
end
if nTran==0, S=[]; return; end

% handle edge cases for spike table
vlKill = (viUp + spkLim1(1) < 1) | ...
    viDn + spkLim1(2) > size(mrData, 1);
viUp(vlKill) = [];
viDn(vlKill) = [];
nTran = nTran - sum(vlKill);

% Kill refrac
if P.tRefrac > 0
    nRefrac = round(P.tRefrac * P.sRateHz);
    viKill = find(diff(viUp) < nRefrac) + 1;
    viUp(viKill) = [];
    viDn(viKill) = [];
    nTran = nTran - numel(viKill);
    fprintf('%d spikes killed\n', numel(viKill));
end

% Mark channels that crossed transitions
trSpkWav = zeros([diff(spkLim1)+1, nChans, nTran], 'single');
mlTran = false(nChans, nTran); %if a channel crossed threshold or not
viTime = zeros(1, nTran);
% miTime = zeros(nChans, nTran, 'single');
viRange0 = P.spkLim(1):P.spkLim(2);
viRange1 = spkLim1(1):spkLim1(2);

% for each transition copy spike table
for iTran = 1:nTran
    viRange = viUp(iTran):viDn(iTran);
    mlTran(:,iTran) = any(mlData(:,viRange)');  
    
    % Find spike marker
    switch lower(P.vcPeak)
        case 'min'
            [vr, vi] = min(mrData(viRange, :));   
            [~, ispk] = min(vr);
            viTime(iTran) = vi(ispk) + viUp(iTran) - 1;
        case 'max'
            [vr, vi] = max(mrData(viRange, :));   
            [~, ispk] = max(vr);
            viTime(iTran) = vi(ispk) + viUp(iTran) - 1;
        case 'vpp' %align at mininum for channel having max vpp
            [vrMax, viMax] = max(mrData(viRange, :));   
            [vrMin, viMin] = min(mrData(viRange, :));   
            [~, ispk] = max(vrMax-vrMin);
            viTime(iTran) = viMin(ispk) + viUp(iTran) - 1;
        case 'sdsummax'
            [~, ispk] = max(sum(mrData(viRange, :).^2));   
            viTime(iTran) = ispk + viUp(iTran) - 1;
        case 'pwrsummax'
            [vrMin1, viTime1] = min(mrData(viRange, :));   
            vrMin2 = (vrMin1) .^ 4;
            viTime(iTran) = round(sum(viTime1 .* vrMin2) ./ sum(vrMin2)) + viUp(iTran) - 1; %weighted time
        otherwise
            error('buildSpikeTable-incorrect vcPeak: %s', P.vcPeak);
    end     
    trSpkWav(:, :, iTran) = ...
        mrData(viRange1 + viTime(iTran), :);
end %for tran

S = struct('vrTime', viTime/P.sRateHz, 'mlTran', mlTran, ...
    'vrThresh', vrThresh, 'trSpkWav', trSpkWav, ...
    'viChanPair1', viChanPair1, 'viChanPair2', viChanPair2, 'Sclu', [], ...
    'tLoaded', P.tLoaded, 'sRateHz', P.sRateHz);

if P.fMeasureEvent
    S.vnEvtNChan = sum(mlTran);
    S.vrEvtAmp = max(getFeatures(trSpkWav, P));    
    if ~P.fCluster %no need to keep
        S.trSpkWav = [];
    end
end