%% single day plot. only plot shank 1 & 2
%freqLim:  [300 3000]   [500 11875]
%thresh: [2 4]  []
obj = Animal('ANM282996');
tOffset = 0;
tDuration = 20;

viDay = [21];
viShank = [1];
figure;
tic
cSfet = obj.plotClusters('viDay', viDay, 'readDuration', [0 tDuration]+tOffset, ...
    'maxAmp', 500, 'fUseSubThresh', 0, 'freqLim', [300 3000], ...
    'fMeanSubt', 1, 'thresh', [2 4], 'viShank', viShank, 'vcPeak', 'Vpp', ...
    'fSpkWav', 1, 'fPlot', 0);
toc
% return;

save ANM282996_Day21Shank1 cSfet viDay viShank;

%% cluster science method


profile clear; profile on; tic


for iDay1 = 1:numel(viDay)
    for iShank1 = 1:numel(viShank)        
        tic;
        Sclu = clusterScience(cSfet{iDay1}{iShank1}.mrPeak, ...
            'fPlot', 0, 'ginput', [0.9458, 205.7838], 'vcDist', 'euclidean');
        toc
        cSfet{iDay1}{iShank1}.viClu = Sclu.halo;
    end
end

toc; profile off; profile viewer;

%%
for iDay1 = 1:numel(viDay)
    for iShank1 = 1:numel(viShank)        
        nClu = max(cSfet{iDay1}{iShank1}.viClu);
        fprintf('iDay:%d, iShank:%d, %d clu\n', iDay1, iShank1, nClu);
    end
end
% iDay:1, iShank:1, 2 clu
% iDay:1, iShank:2, 1 clu
% iDay:2, iShank:1, 3 clu
% iDay:2, iShank:2, 4 clu
% iDay:3, iShank:1, 3 clu
% iDay:3, iShank:2, 6 clu
% iDay:4, iShank:1, 6 clu
% iDay:4, iShank:2, 3 clu

%% bar plot
title('Number of clusters');
figure; bar([2 1; 3 4; 3 6; 6 3], 'stacked')
set(gca, 'XTickLabel', obj.csXTickLabel(viDay));
xlabel('Days after implantation');
legend({'Shank1', 'Shank2'});
ylabel('Number of clusters');
title('Rat 2, Shank 1,2')

%%
S = cSfet{1}{1};
viClu = S.viClu;
figure;
plotTetClu(S.mrPeak, 'viClu', viClu, 'maxAmp', 800);
% colormap jet;
title(sprintf('%s, nClu:%d', S.vcDate, max(viClu)));
% set(gca, 'Color', 'w');

figure; hold on;
mrColor = jet(max(viClu));
for iClu = 1:max(viClu)
    viCluPlot = find(viClu==iClu);
    vrX = [1:size(S.trSpkWav, 1)] + size(S.trSpkWav, 1)*(iClu-1);
    for iChan = 1:size(S.trSpkWav, 2)
        mrY = reshape(S.trSpkWav(:,iChan,viCluPlot), [25, numel(viCluPlot)]) + iChan*300;
        plot(vrX, mrY, 'Color', mrColor(iClu,:), 'LineWidth', .5);
    end
end
axis tight;
set(gca, {'XTick', 'YTick', 'Color'}, {[], [], 'k'});

%%
% mrFet0 = load('example_distances.dat');
% clusterScience(mrFet0);



%%

% 
% %%
% vcFullpath = obj.cs_fname{iDay};
% [~,vcFilename,~] = fileparts(vcFullpath);
% tic
% [cmData, Sfile] = importWhisper(vcFullpath, 'readDuration', readDuration, ...
%     'viChan', {obj.cvShankChan}, 'freqLim', freqLim, 'fMeanSubt', 1);
% toc
% 
% %%
% % warning off;
% figure;
% tic
% cS = detectPeaks(cmData, 'maxAmp', 800, 'fPlot', 1, 'fUseSubThresh', 0, 'vcPeak', 'Vpp');
% toc
% title(sprintf('%s, t(s):%d-%d, %s', vcFilename, readDuration(1), readDuration(2), get(gcf, 'Name')));

%%
% figure; scatter(cS{1}.vrPosX, cS{1}.vrPosY, 10, cS{1}.vrAmp, 'filled');
% % figure; scatter3(S.vrPosX, S.vrPosY, S.vrAmp, 5, S.vrAmp, 'filled');
% colormap jet; set(gca, 'CLim', [0 300]);
% 
% %% latent variable
% pcCutoff= .995;
% [COEFF,SCORE,latent,tsquare] = princomp(S.mrPeak);
% vrPcLat = cumsum(latent)/sum(latent);
% nClu = sum(vrPcLat<pcCutoff);
% figure; plot(vrPcLat(1:nClu));
% 
% [~, viClu] = max(abs(COEFF(:, 1:nClu)'));
% figure; hist(viClu, 1:nClu);