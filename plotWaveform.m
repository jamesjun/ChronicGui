function plotWaveform(S, varargin)
P = funcInStr(varargin{:});
if ~isfield(P, 'iMax'), P.iMax = 1; end
if ~isfield(P, 'maxAmp'), P.maxAmp = maxAmp; end

viClu = S.Sclu.halo;
mrColor = jet(max(viClu)+1);
nChans = size(S.trSpkWav, 2);
nTimeSpk = size(S.trSpkWav, 1); 
ylim = [0 (nChans+1) * P.maxAmp];
for iClu = 1:max(viClu)
    viCluPlot = find(viClu==iClu);
    xoff = size(S.trSpkWav, 1)*(iClu-1);
    vrX = [1:size(S.trSpkWav, 1)] + xoff;
    for iChan = 1:nChans
        mrY = reshape(S.trSpkWav(:,iChan,viCluPlot), [nTimeSpk, numel(viCluPlot)]) + iChan * P.maxAmp;
        plot(vrX, mrY, 'Color', mrColor(iClu,:), 'LineWidth', .5);
    end
    hold on; plot(P.iMax*[1 1]-1+xoff, ylim, 'w-');
end
axis tight;
set(gca, {'XTick', 'YTick', 'Color'}, {[], [], 'k'});
title(sprintf('#Spikes: %d, #Clu: %d', sum(viClu>0), max(viClu)))
% set(gcf, 'Name', vcTitle);
end