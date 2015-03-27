function plotWaveform(S, varargin)
P = funcDefStr(funcInStr(varargin{:}), ...
    'spkLim', [-8, 12], 'maxAmp', 1000, 'nSpkMax', inf, 'nPadding', 0);

viClu = S.Sclu.cl;

if max(viClu) == 1, return; end

mrColor = [.5, .5, .5; jet(max(viClu)-1)];

% trim off the padding
if P.nPadding > 0
    trSpkWav = S.trSpkWav((1+P.nPadding):(end-P.nPadding),:,:);
else
    trSpkWav = S.trSpkWav;
end
iMax = -P.spkLim(1);
nChans = size(trSpkWav, 2);
nTimeSpk = size(trSpkWav, 1); 
ylim([0 (nChans+1) * P.maxAmp]);
xlim([0, (max(viClu)-1) * size(trSpkWav, 1)+1]);
% set(gcf, 'Visible', 'off'); %try-catch?
hold on;
mrYoff = repmat((1:nChans) * P.maxAmp, [nTimeSpk, 1]);
for iClu = 2:max(viClu)
    viCluPlot = find(viClu==iClu);
    nSpkClu = numel(viCluPlot);
%     if isnan(S.vrIsoDist(iClu)), continue; end %skip if isnan
%     if S.vrIsoDist(iClu) < 30, continue; end %distance too low
    if nSpkClu > P.nSpkMax
        viPlot = random('unid', nSpkClu, [P.nSpkMax,1]);
        viCluPlot = viCluPlot(viPlot);
    end
    
%     viCluPlot = viCluPlot(1); % plot only one
    xoff = size(trSpkWav, 1)*(iClu-2);
    vrX = [1:size(trSpkWav, 1)] + xoff;
    mrY = reshape(trSpkWav(:,:,viCluPlot), [nTimeSpk, nChans * numel(viCluPlot)]) ...
        + repmat(mrYoff, [1, numel(viCluPlot)]);
%     for iChan = 1:nChans %collapse double loop
% %       mrY = reshape(S.trSpkWav(:,iChan,viCluPlot), [nTimeSpk, numel(viCluPlot)]) + iChan * P.maxAmp;
%         mrY(:,iChan,:) = trY(:,iChan,:) + iChan * P.maxAmp;
%     end
    plot(vrX, mrY, 'Color', mrColor(iClu,:), 'LineWidth', .5);
    plot(iMax*[1 1]+xoff+1, ylim, 'w-');
end
% set(gcf,'Visible','on');
% axis tight;
set(gca, {'XTick', 'YTick', 'Color'}, {[], [], 'k'});
title(sprintf('#Spikes: %d, #Clu: %d', sum(viClu>1), max(viClu)-1))
% set(gcf, 'Name', vcTitle);
end