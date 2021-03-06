function S = detectPeaks(mrData, P, iShank1)
% per each channels
P = funcDefStr(P, ...
    'sRateHz', 25000, 'maxAmp', 1000, 'fPlot', 0, 'fUseSubThresh', 1, ...
    'vcPeak', 'Vpp', 'shankOffY', 0, 'thresh', [], 'vcDate', '', ...
    'spkLim', [-8, 16], 'fSpkWav', 0, 'nInterp', 1, ...
    'fKillRefrac', 0, 'nPadding', 0, ...
    'vcPlotType', 'cluster', 'keepFraction', 1, 'cmWavRef', [], ...
    'fDiffPair', 0);
if nargin < 3
    iShank1 = [];
end
if nargout == 0, P.fPlot = 1; end

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

%generate transition markers
if ~isempty(vrThreshW) 
    %do not convolve vlData for dual threshold scheme
    mlData = bsxfun(@lt, mrData, -vrThreshW)'; %widen the mask
    vlData = logical(any(mlData));
    
    % convolve vlData for merging purpose
    nOneMs = round(.0005 * P.sRateHz);
    vlData = logical(conv(double(vlData), ones(nOneMs,1), 'same'));
    
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
        [zeros(1, -P.spkLim(1)), ones(1, P.spkLim(2))], 'same'));
    [viUp, viDn, nTran] = findTrans(vlData);
end
if nTran==0, S=[]; return; end

% handle edge cases for spike table
if viUp(1) + spkLim1(1) < 1
    viUp(1) = [];   viDn(1) = [];   nTran = nTran-1;
end
if viDn(end) + spkLim1(2) > size(mrData, 1)
    viUp(end) = [];   viDn(end) = [];   nTran = nTran-1;
end

% Kill refrac
if P.fKillRefrac
    nRefrac = round(.001 * P.sRateHz);
    viKill = find(diff(viUp) < nRefrac) + 1;
    viUp(viKill) = [];
    viDn(viKill) = [];
    nTran = nTran - numel(viKill);
    fprintf('%d spikes killed\n', numel(viKill));
end

% Mark channels that crossed transitions
if P.fSpkWav
    trSpkWav = zeros([diff(spkLim1)+1, nChans, nTran], 'single');
else
    trSpkWav = [];
end
mlTran = false(nChans, nTran); %if a channel crossed threshold or not
mrMax = zeros(nChans, nTran, 'single');
mrMin = zeros(nChans, nTran, 'single');
viTime = zeros(1, nTran);
% miTime = zeros(nChans, nTran, 'single');
viRange0 = P.spkLim(1):P.spkLim(2);
viRange1 = spkLim1(1):spkLim1(2);
if P.nInterp > 1
    viRangeInt0 = P.spkLim(1):(1/P.nInterp):P.spkLim(2);
else
    viRangeInt0 = [];
end

% @TODO: Max SD and return features
for iTran = 1:nTran
%     try
    %find min
    viRange = viUp(iTran):viDn(iTran);
    mlTran(:,iTran) = any(mlData(:,viRange)');  
    viChanZero = find(~mlTran(:,iTran));    
    
    % Find spike marker
    switch lower(P.vcPeak)
        case min
            [vr, vi] = min(mrData(viRange, :));   
            [~, ispk] = min(vr);
            viTime(iTran) = vi(ispk) + viUp(iTran) - 1;
        case max
            [vr, vi] = max(mrData(viRange, :));   
            [~, ispk] = max(vr);
            viTime(iTran) = vi(ispk) + viUp(iTran) - 1;
        case sdsummax
            [~, ispk] = max(sum(mrData(viRange, :).^2));   
            viTime(iTran) = ispk + viUp(iTran) - 1;
        case pwrsummax
            [vrMin1, viTime1] = min(mrData(viRange, :));   
            vrMin2 = (vrMin1) .^ 4;
            viTime(iTran) = round(sum(viTime1 .* vrMin2) ./ sum(vrMin2)) + viUp(iTran) - 1; %weighted time
    end     

    viRange = viRange0 + viTime(iTran);  %update the range  
    mrData1 = mrData(viRange, :);
    if ~isempty(viRangeInt0)
        mrData1 = interp1(viRange, mrData1, ...
            viRangeInt0 + viTime(iTran), 'spline');
    end
    mrMin(:,iTran) = min(mrData1);  %update value
    mrMax(:,iTran) = max(mrData1);     
    if P.fSpkWav
        if P.fUseSubThresh  
            trSpkWav(:, :, iTran) = ...
                mrData(viRange1 + viTime(iTran), :);
        else
            viChanCross = find(mlTran(:,iTran));
            trSpkWav(:, viChanCross, iTran) = ...
                mrData(viRange1 + viTime(iTran), viChanCross);
        end
    end
    if ~P.fUseSubThresh        
        mrMax(viChanZero, iTran) = 0;
        mrMin(viChanZero, iTran) = 0;  
    end
%     catch err
%         disp(err)
%     end
end

% common average subtraction
mrT = P.cmWavRef{iShank1}';
if ~isempty(mrT)
    mrMax = mrT * mrMax;
    mrMin = mrT * mrMin;
end
switch (P.vcPeak)
    case 'Vpp'
        mrPeak = mrMax - mrMin;
    case 'Vm'
        mrPeak = abs(mrMin);
end

if P.keepFraction < 1
    vrFet = sum(mrPeak.^2);
    viFet1 = find(vrFet > quantile(vrFet, 1-P.keepFraction)); %debug
    mrPeak = mrPeak(:, viFet1);
    mrMin = mrMin(:, viFet1);
    trSpkWav = trSpkWav(:, :, viFet1);
    viTime = viTime(viFet1);
end

% vrTimeSd = sqrt((sum(mrPeak .* miTime.^2 ) ./ sum(mrPeak)) - vrTime.^2);
vrTime = viTime  / P.sRateHz;
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

% if P.fCov, mrCov = calcCov(trSpkWav, P);
% else mrCov = []; end

S = struct('mrPeak', mrPeak, 'vrAmp', vrAmp, 'vrTime', vrTime, ...
    'mlTran', mlTran, 'vrPosX', vrPosX, 'vrPosY', vrPosY, 'vrPeak', vrPeak, ...
    'vrThresh', vrThresh, 'nTets', nTets, 'vcDate', P.vcDate, ...
    'trSpkWav', trSpkWav, 'nPadding', P.nPadding, ...
    'spkLim', P.spkLim, 'Sclu', [], 'mrMin', mrMin, ...
    'viChanPair1', viChanPair1, 'viChanPair2', viChanPair2);

if P.fPlot
    switch lower(P.vcPlotType)
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
        plotTetClu(mrPeak, P);
%         if nChans == 11, viTetChOff = [0 4 7];
%         else viTetChOff = 0:4:nChans-4;
%         end
%         nTets = numel(viTetChOff);
%         mrTet = [1 1 1 2 2 3; 2 3 4 3 4 4];
%         nPairs = size(mrTet,2);
%         set(gca, {'Color', 'XTick', 'YTick'}, {'k',[],[]});
%         axis equal;
%         hold on;
%         for iTet = nTets:-1:1
%            for iPair = 1:nPairs
%                 ch1 = mrTet(1, iPair) + viTetChOff(iTet);
%                 ch2 = mrTet(2, iPair) + viTetChOff(iTet);
%                 vrX1 = linmap(mrPeak(ch2,:), [0 P.maxAmp], [0 1]) + (iPair-1);
%                 vrY1 = linmap(mrPeak(ch1,:), [0 P.maxAmp], [0 1]) + (iTet-1) + P.shankOffY;          
%                 plot(vrX1, vrY1, 'w.', 'MarkerSize', 1);
%                 plot([0 0 1 1 0]+iPair-1, [0 1 1 0 0]+iTet-1 + P.shankOffY, 'w');
%            end
%         end        
%         set(gcf, 'Name', sprintf('%s:%duV, Thresh:%s', P.vcPeak, P.maxAmp, vcThresh));
% %         title(sprintf('%s:0..%d, Thresh:%s', vcPlot, maxamp, vcThresh));
%         axis([0, nPairs, 0, nTets + P.shankOffY]);
%         plot([0 0 1 1 0]*nPairs, [0 1 1 0 0]*nTets + P.shankOffY, 'w', 'LineWidth', 2);
% %         try tightfig; catch; disp(lasterr); end
    end %switch
end %if
