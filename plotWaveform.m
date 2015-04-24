function plotWaveform(S, varargin)
P = funcDefStr(funcInStr(varargin{:}), ...
    'spkLim', [-8, 12], 'maxAmp', 1000, 'nSpkMax', inf, 'nPadding', 0, ...
    'fKeepNoiseClu', 1, 'iCluNoise', 1);

viClu = S.Sclu.cl;
if max(viClu) == 1, return; end

mrColor = [.5, .5, .5; jet(max(viClu)-1)];

% trim off the padding
if P.nPadding > 0
    trSpkWav = S.trSpkWav((1+P.nPadding):(end-P.nPadding),:,:);
else
    trSpkWav = S.trSpkWav;
end
% if ~isempty(S.viSpk)
% %     S.vrTime = S.vrTime(viSpk);
%     trSpkWav = trSpkWav(:,:,S.viSpk);
% end
try
    viCluOrder = [];
    [~, vi] = sort(S.Sclu.viChanMin(2:end), 'descend');
    viCluOrder(vi) = 2:max(viClu);
catch err
    viCluOrder = [2:max(viClu)];
end
viCluOrder = [1, viCluOrder];
iMax = -P.spkLim(1)+1;
nChans = size(trSpkWav, 2);
nTimeSpk = size(trSpkWav, 1); 
maxAmp = P.maxAmp;
ylim([0 (nChans+1) * maxAmp]);
xlim([0, (max(viClu)) * size(trSpkWav, 1)+1]);
% set(gcf, 'Visible', 'off'); %try-catch?
hold on;
mrYoff = repmat((1:nChans) * maxAmp, [nTimeSpk, 1]);
if ~P.fKeepNoiseClu
    viClu = viClu(viClu>1);
end
vrXTick = zeros(1,max(viClu));
vnSpkClu = zeros(1,max(viClu));
for iClu = 1:max(viClu)
    iClu1 = viCluOrder(iClu);
    viCluPlot = find(viClu==iClu);
    if isempty(viCluPlot), continue; end
    nSpkClu = numel(viCluPlot);
%     if isnan(S.vrIsoDist(iClu)), continue; end %skip if isnan
%     if S.vrIsoDist(iClu) < 30, continue; end %distance too low
    mrYm = reshape(mean(trSpkWav(:,:,viCluPlot),3), nTimeSpk, []) + mrYoff;
    
    if nSpkClu > P.nSpkMax
        viPlot = random('unid', nSpkClu, [P.nSpkMax,1]);
        viCluPlot = viCluPlot(viPlot);
    end
    
%     viCluPlot = viCluPlot(1); % plot only one
    xoff = size(trSpkWav, 1)*(iClu1-1);
    vrX = [1:size(trSpkWav, 1)] + xoff;
    mrY = reshape(trSpkWav(:,:,viCluPlot), [nTimeSpk, nChans * numel(viCluPlot)]) ...
        + repmat(mrYoff, [1, numel(viCluPlot)]);
%     if strcmpi(P.vcFet, 'pairvpp') && ~isempty(viChanMin)
%         mrYmin = trSpkWav(iMax,viChanMin(iClu),viCluPlot);
%         viChan1 = 1:nChans;
%         for iSpk = 1:numel(viCluPlot)
%             mrY(:, viChan1) = mrY(:, viChan1) - mrYmin(iSpk);
%             viChan1 = viChan1 + nChans;
%         end
%     end

    plot(vrX, mrY, 'Color', mrColor(iClu,:), 'LineWidth', .5);
    plot(vrX, mrYm, 'w-', 'LineWidth', .5);
    plot(iMax*[1 1]+xoff, ylim, 'w-');
    vrXTick(iClu1) = iMax + xoff;
    vnSpkClu(iClu) = nSpkClu;
end
% set(gcf,'Visible','on');
% axis tight;
set(gca, {'YTick', 'Color'}, {[], 'k'});
set(gca, 'XTick', vrXTick);
set(gca, 'XTickLabel', vnSpkClu);
xlabel('# Spikes');
ylabel('Chan #');
nSpkClustered = sum(viClu>P.iCluNoise);
title(sprintf('#Spikes: %d (%0.1f %%clustered), #Clu: %d', ...
    nSpkClustered, nSpkClustered/numel(viClu)*100, max(viClu)-P.iCluNoise))
% set(gcf, 'Name', vcTitle);
end