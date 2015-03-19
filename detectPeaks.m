function S = detectPeaks(mrData, varargin)
% per each channels
vcPlotType = 'cluster'; %raster cluster
nChans = size(mrData, 2);

if isstruct(varargin{1})
    P = varargin{1};
else
    P = struct(varargin{:});
end
if ~isfield(P, 'sRateHz'), P.sRateHz = 25000; end
if ~isfield(P, 'maxAmp'), P.maxAmp = 600; end
if ~isfield(P, 'fPlot'), P.fPlot = (nargout == 0); end
if ~isfield(P, 'fUseSubThresh'), P.fUseSubThresh = 1; end
if ~isfield(P, 'vcPeak'), P.vcPeak = 'Vpp'; end
if ~isfield(P, 'shankOffY'), P.shankOffY = 0; end
if ~isfield(P, 'thresh'), P.thresh = []; end %[] for QQ, scalar for fixed val, two-element vector for double-thresh
if ~isfield(P, 'vcDate'), P.vcDate = ''; end
if ~isfield(P, 'spkLim'), P.spkLim = [-8, 16]; end
if ~isfield(P, 'fSpkWav'), P.fSpkWav = 0; end %build spike table

% multi-shank support
if iscell(mrData)
    S = cell(size(mrData));
    if P.fPlot, hold on; end
    P.shankOffY = 0;
    for iShank = numel(mrData):-1:1
        S{iShank} = detectPeaks(mrData{iShank}, P);
        P.shankOffY = P.shankOffY + S{iShank}.nTets;
    end
    return;
end

vrThreshW = []; %week threshold
if isempty(P.thresh)
    vrThresh = 5 * median(abs(mrData))/0.6745;  % default methods
    vcThresh = 'QQ';
else
    if numel(P.thresh) == 1
        vcThresh = sprintf('%d', P.thresh);
        vrThresh = repmat(P.thresh, [1, nChans]);
    elseif numel(P.thresh) == 2
        vcThresh = sprintf('SD%d-%d', round(P.thresh(1)), round(P.thresh(2)));
        vrThresh = std(mrData) * max(P.thresh);  % default methods
        vrThreshW = std(mrData) * min(P.thresh);
    end
end

mlData = bsxfun(@lt, mrData, -vrThresh)';
vlData = logical(conv(double(any(mlData)), [zeros(1, -P.spkLim(1)), ones(1, P.spkLim(2))], 'same'));
if ~isempty(vrThreshW)
    mlData = bsxfun(@lt, mrData, -vrThreshW)'; %widen the mask
end
try
    viUp = find(diff(vlData) > 0);
    viDn = find(diff(vlData) < 0);
    if viDn(1) < viUp(1), viDn(1) = []; end
    nTran = min(numel(viDn), numel(viUp));
    viUp = viUp(1:nTran);
    viDn = viDn(1:nTran);
catch
    viUp = [];
    viDn = [];
    nTran = 0;
    S = [];
    return;
end

% Mark channels that crossed transitions
mlTran = false(nChans, nTran);
mrMax = zeros(nChans, nTran);
mrMin = zeros(nChans, nTran);
miTime = zeros(nChans, nTran);
for iTran = 1:nTran
    viRange = viUp(iTran):viDn(iTran);
    [mrMin(:,iTran), miTime(:,iTran)] = min(mrData(viUp(iTran):viDn(iTran), :)); 
    mrMax(:,iTran) = max(mrData(viUp(iTran):viDn(iTran), :)); 
    mlTran(:,iTran) = any(bsxfun(@and, mlData(:,viRange), vlData(viRange))');
    if ~P.fUseSubThresh
        viChanZero = find(~mlTran(:,iTran));
        mrMax(viChanZero, iTran) = 0;
        mrMin(viChanZero, iTran) = 0;
    end
end

switch (P.vcPeak)
    case 'Vpp'
        mrPeak = mrMax - mrMin;
    case 'Vm'
        mrPeak = abs(mrMin);
end

% Align time for spike table
trSpkWav = [];
mrPeakSq = mrPeak.^2; %following Masked Klustakwik paper 2015 Archive
viTime = round(sum(mrPeakSq .* miTime) ./ sum(mrPeakSq)) + viUp; %weighted time
if P.fSpkWav
    nSpkWav = diff(P.spkLim)+1;
    trSpkWav = zeros(nSpkWav, nChans, nTran);
    viRange0 = P.spkLim(1):P.spkLim(2);
    for iTran = 1:nTran
        try
            viRange1 = viRange0 + viTime(iTran);
            trSpkWav(:, :, iTran) = mrData(viRange1, :);
        catch
            disp(lasterr);
        end
    end
end

% vrTimeSd = sqrt((sum(mrPeak .* miTime.^2 ) ./ sum(mrPeak)) - vrTime.^2);
% vrTime = (viUp + vrTime)  / P.sRateHz;
% vrTimeSd = vrTimeSd  / P.sRateHz;

% vrAmp = sqrt(sum(mrPeak .* mrPeak));
% vrAmp = sum(mrPeak);
vrAmp = max(mrPeak);

vrChanPos = (1:nChans)';
% vrPos = sum(bsxfun(@times, mrPeak, vrChanPos)) ./ sum(mrPeak); %weighted pos
% vrPosSd = sqrt((sum(bsxfun(@times, mrPeak, vrChanPos.^2)) ./ sum(mrPeak)) - vrPos.^2);

% plot location of peaks
vrPosXe = repmat([0; 1], [1, 8]); vrPosXe = vrPosXe(:);
vrPosXe = vrPosXe(1:nChans);
vrPosYe = (1:nChans)';
vrPeak = sum(mrPeak);
vrPosX = sum(bsxfun(@times, mrPeak, vrPosXe)) ./ vrPeak;
vrPosY = sum(bsxfun(@times, mrPeak, vrPosYe)) ./ vrPeak;

nTets = round(nChans/4);

S = struct('mrPeak', mrPeak, 'vrAmp', vrAmp, 'viTime', viTime, ...
    'mlTran', mlTran, 'vrPosX', vrPosX, 'vrPosY', vrPosY, 'vrPeak', vrPeak, ...
    'vrThresh', vrThresh, 'nTets', nTets, 'vcDate', P.vcDate, 'trSpkWav', trSpkWav);

if P.fPlot
    switch lower(vcPlotType)
        case 'raster'
        mtPeak = bsxfun(@plus, miTime, viUp) / P.sRateHz;
        CLIM = [0 P.maxAmpl];
        mrPos = repmat(vrChanPos, [1, nTran]);
%         mrAmp = repmat(vrAmp, [nChans, 1]);

        vrY = mrPos(mlTran)';
        vrX = mtPeak(mlTran)';
    %     vrC = mrAmp(mlTran)';
        vrC = mrPeak(mlTran)';

        caxis(CLIM);
        patch(repmat(vrX, [2 1]), bsxfun(@plus, vrY, [-.5; .5]), ...
        repmat(vrC, [2 1]), 'EdgeColor', 'flat');
    %     colormap jet;   set(gca, 'Color', [0 0 .5]);
        colormap hot;   set(gca, 'Color', 'k');
        %axis([0 obj.readDuration, .5 nChans1+.5]);
        
        
        case 'cluster'            
        if nChans == 11, viTetChOff = [0 4 7];
        else viTetChOff = 0:4:nChans-4;
        end
        nTets = numel(viTetChOff);
        mrTet = [1 1 1 2 2 3; 2 3 4 3 4 4];
        nPairs = size(mrTet,2);
        set(gca, {'Color', 'XTick', 'YTick'}, {'k',[],[]});
        axis equal;
        hold on;
        for iTet = nTets:-1:1
           for iPair = 1:nPairs
                ch1 = mrTet(1, iPair) + viTetChOff(iTet);
                ch2 = mrTet(2, iPair) + viTetChOff(iTet);
                vrX1 = linmap(mrPeak(ch2,:), [0 P.maxAmp], [0 1]) + (iPair-1);
                vrY1 = linmap(mrPeak(ch1,:), [0 P.maxAmp], [0 1]) + (iTet-1) + P.shankOffY;          
                plot(vrX1, vrY1, 'w.', 'MarkerSize', 1);
                plot([0 0 1 1 0]+iPair-1, [0 1 1 0 0]+iTet-1 + P.shankOffY, 'w');
           end
        end        
        set(gcf, 'Name', sprintf('%s:%duV, Thresh:%s', P.vcPeak, P.maxAmp, vcThresh));
%         title(sprintf('%s:0..%d, Thresh:%s', vcPlot, maxamp, vcThresh));
        axis([0, nPairs, 0, nTets + P.shankOffY]);
        plot([0 0 1 1 0]*nPairs, [0 1 1 0 0]*nTets + P.shankOffY, 'w', 'LineWidth', 2);
%         try tightfig; catch; disp(lasterr); end
    end %switch
end %if
