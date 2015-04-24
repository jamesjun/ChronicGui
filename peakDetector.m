function [viPeak, viTrough] = peakDetector(vrWav, varargin)
%vrA: peak ampl, vnI: prev Interval
P = funcDefStr(funcInStr(varargin{:}), ...
    'fPlot', 0, 'peakThresh', [], 'troughThresh', [], 'minInterval', []);

nChans = size(vrWav,2);
nSamples = size(vrWav,1);

if nChans > 1
    viPeak = cell(nChans,1);
    if nargout == 1
        for iChan=1:nChans
            viPeak{iChan} = peakDetector(vrWav(:,iChan), P);
        end
    else
        viTrough = cell(nChans,1);
        for iChan=1:nChans
            [viPeak{iChan}, viTrough{iChan}] = peakDetector(vrWav(:,iChan), P);
        end
    end
    return;
end

vrTran = diff(diff(vrWav) > 0);
viPeak = find(vrTran < 0)+1;
if ~isempty(P.peakThresh)
    vlKeep = vrWav(viPeak) > P.peakThresh;   
    %plotPrePost(vrWav, viPeak, vlKeep, 'Peak', P);
    viPeak = viPeak(vlKeep);
else
    plotPrePost(vrWav, viPeak, [], 'Peak', P);
end
if ~isempty(P.minInterval)
    while 1
        iKill = find(diff(viPeak) < P.minInterval, 1, 'first');
        if isempty(iKill), break; end
        viPeak(iKill+1) = [];
    end
end
plotPrePost(vrWav, viPeak, [], 'Peak', P);

if nargout > 1
    viTrough = find(vrTran > 0)+1;

    if P.fPlot
        figure; plot(vrWav(viPeak(2:end)), diff(viPeak), '.'); 
        set(gca, 'XScale' ,'log'); 
        set(gca, 'YScale', 'log');
        xlabel('Trough Ampl'); ylabel('Trough Intervals');
        title('Trough distribution');
    end

    if ~isempty(P.troughThresh)
        vlKeep = vrWav(viTrough) < P.troughThresh;
        plotPrePost(vrWav, viTrough, vlKeep, 'Trough', P);
        viTrough = viTrough(vlKeep);
    end
else
    viTrough = [];
end

if P.fPlot
    figure;
    plot(vrWav, 'k-');
    hold on;
    plot(viPeak, vrWav(viPeak), 'ro');
    if ~isempty(P.peakThresh)
        plot([1, numel(vrWav)], P.peakThresh*[1 1], 'r-');
    end
    if ~isempty(viTrough)
        plot(viTrough, vrWav(viTrough), 'b.'); 
        if ~isempty(P.troughThresh)
            plot([1, numel(vrWav)], P.troughThresh*[1 1], 'b-');
        end
    end
end

end %func

function plotPrePost(vrWav, viPeak, vlKeep, vcTitle, P)
if ~P.fPlot, return; end

figure; hold on;
vrX = vrWav(viPeak);
vrY = [0; diff(viPeak)];
plot(vrX, vrY, 'k.');
if ~isempty(vlKeep)
    plot(vrX(vlKeep), vrY(vlKeep), 'r.');
end
% set(gca, 'XScale' ,'log'); 
% set(gca, 'YScale', 'log');
xlabel('Ampl'); ylabel('Intervals'); 
title(vcTitle);
end
