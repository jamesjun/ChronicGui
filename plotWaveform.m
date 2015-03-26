function plotWaveform(S, varargin)
P = funcInStr(varargin{:});
if ~isfield(P, 'iMax'), P.iMax = 1; end
if ~isfield(P, 'maxAmp'), P.maxAmp = maxAmp; end

viClu = S.Sclu.halo;
mrColor = [.5, .5, .5; jet(max(viClu)-1)];
nChans = size(S.trSpkWav, 2);
nTimeSpk = size(S.trSpkWav, 1); 
ylim([0 (nChans+1) * P.maxAmp]);
xlim([1 max(viClu)] * size(S.trSpkWav, 1));
% set(gcf, 'Visible', 'off');
hold on;
mrYoff = repmat((1:nChans) * P.maxAmp, [nTimeSpk, 1]);
for iClu = 2:max(viClu)
    viCluPlot = find(viClu==iClu);
%     if isnan(S.vrIsoDist(iClu)), continue; end %skip if isnan
%     if S.vrIsoDist(iClu) < 30, continue; end %distance too low
    
%     viCluPlot = viCluPlot(1); % plot only one
    xoff = size(S.trSpkWav, 1)*(iClu-1);
    vrX = [1:size(S.trSpkWav, 1)] + xoff;
    mrY = reshape(S.trSpkWav(:,:,viCluPlot), [nTimeSpk, nChans * numel(viCluPlot)]) ...
        + repmat(mrYoff, [1, numel(viCluPlot)]);
%     for iChan = 1:nChans %collapse double loop
% %       mrY = reshape(S.trSpkWav(:,iChan,viCluPlot), [nTimeSpk, numel(viCluPlot)]) + iChan * P.maxAmp;
%         mrY(:,iChan,:) = trY(:,iChan,:) + iChan * P.maxAmp;
%     end
    reduce_plot(vrX, mrY, 'Color', mrColor(iClu,:), 'LineWidth', .5);
    plot(P.iMax*[1 1]+xoff+1, ylim, 'w-');
end
% set(gcf,'Visible','on');
% axis tight;
set(gca, {'XTick', 'YTick', 'Color'}, {[], [], 'k'});
title(sprintf('#Spikes: %d, #Clu: %d', sum(viClu>1), max(viClu)-1))
% set(gcf, 'Name', vcTitle);
end