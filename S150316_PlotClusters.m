% %% single day plot. only plot shank 1 & 2
% %freqLim:  [300 3000]   [500 11875]
% %thresh: [2 4]  []
% obj = Animal('ANM282996');
% tOffset = 0;
% tDuration = 20;
% spkLim = [-8, 12];
% viDay = [21];
% viShank = [1];
% % figure;
% tic
% [cSfet, vcTitle] = obj.plotClusters('viDay', viDay, 'readDuration', [0 tDuration]+tOffset, ...
%     'maxAmp', 500, 'fUseSubThresh', 1, 'freqLim', [300 3000], ...
%     'fMeanSubt', 1, 'thresh', [2 4], 'viShank', viShank, 'vcPeak', 'Vpp', ...
%     'fSpkWav', 1, 'fPlot', 0, 'spkLim', spkLim);
% toc
% obj.plotClusters('maxAmp', 1000);
% return;


%%
warning off;
fParfor = 1;
tOffset = 0;
tDuration = 120;
spkLim = [-8, 12];
viDay = [20,21];
viShank = [1:4];
freqLim = [500 11875];  %[300 3000] [300 6000] [500 11875] 
maxAmp = 1000;
tic
obj = Animal('ANM282996');
obj = obj.getFet('viDay', viDay, 'readDuration', [0 tDuration]+tOffset, ...
    'maxAmp', maxAmp, 'fUseSubThresh', 1, 'freqLim', freqLim, ...
    'fMeanSubt', 1, 'thresh', [2 4], 'viShank', viShank, 'vcPeak', 'Vm', ...
    'fSpkWav', 1, 'fPlot', 0, 'spkLim', spkLim, 'fParfor', fParfor);
% obj = obj.cluster();
toc

tic;
obj = obj.cluster('fPlot', 0, 'vcFet', 'peak', 'vcDist', 'euclidean', ...
    'maxAmp', 1000, 'fNormFet', 0, 'fParfor', fParfor);
% obj.plotClusters('maxAmp', maxAmp);
toc

ANM282996 = obj;
save ANM282996 ANM282996;

%%
obj.plotClusters('maxAmp', 1000);
return;

%%


%%
S = obj1.cmFet{end, end};
figure;

plotTetClu(S.mrPeak, 'viClu', S.Sclu.halo, 'maxAmp', 800);
title(S.vcDate);


%% all clusters
MAX_AMP = 300;
iDay = 1;
iShank = 1;

S = cSfet{iDay}{iShank};
viClu = S.Sclu.halo;
figure;
plotTetClu(S.mrPeak, 'viClu', viClu, 'maxAmp', 800);
% colormap jet;
title(sprintf('%s, nClu:%d', S.vcDate, max(viClu)));
% set(gca, 'Color', 'w'); 

figure; hold on;
mrColor = jet(max(viClu)+1);
nChans = size(S.trSpkWav, 2);
nTimeSpk = size(S.trSpkWav, 1); 
ylim = [0 (nChans+1)*MAX_AMP];
for iClu = 1:max(viClu)
    viCluPlot = find(viClu==iClu);
    xoff = size(S.trSpkWav, 1)*(iClu-1);
    vrX = [1:size(S.trSpkWav, 1)] + xoff;
    for iChan = 1:nChans
        mrY = reshape(S.trSpkWav(:,iChan,viCluPlot), [nTimeSpk, numel(viCluPlot)]) + iChan*MAX_AMP;
        plot(vrX, mrY, 'Color', mrColor(iClu,:), 'LineWidth', .5);
    end
    hold on; plot(-spkLim(1)*[1 1]-1+xoff, ylim, 'w-');
end
axis tight;
set(gca, {'XTick', 'YTick', 'Color'}, {[], [], 'k'});
title(sprintf('#Spikes: %d, #Clu: %d', sum(viClu>0), max(viClu)))
set(gcf, 'Name', vcTitle);


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




%% specific cluster
MAX_AMP = 500;
iDay = 1;
iShank = 1;
iClu = 3;

S = cSfet{iDay}{iShank};
viClu = S.viClu;
% figure;
viSpk = find(viClu == iClu);
plotTetClu(S.mrPeak(:, viSpk), 'viClu', viClu(viSpk), 'maxAmp', 800);
% colormap jet;
title(sprintf('%s, nClu:%d', S.vcDate, max(viClu)));
% set(gca, 'Color', 'w');

figure; hold on;

viCluPlot = find(viClu==iClu);
mrColor = jet(max(viClu)+1);
nChans = size(S.trSpkWav, 2);
nTimeSpk = size(S.trSpkWav, 1); 
vrX = 1:nTimeSpk;
mrX = repmat(vrX', [1, nChans]);
for iSpk1 = 1:numel(viCluPlot)
    iSpk = viCluPlot(iSpk1);
    mrY = reshape(S.trSpkWav(:,:,iSpk), [nTimeSpk, nChans]) + ...
        repmat(1:nChans, [nTimeSpk, 1])*MAX_AMP;
    plot(mrX, mrY, '-', 'Color', rand(1,3), 'LineWidth', .5);
end
hold on; plot(-spkLim(1)*[1 1]-1, get(gca, 'YLim'), 'w-');

    
axis tight;
set(gca, {'XTick', 'YTick', 'Color'}, {[], [], 'k'});