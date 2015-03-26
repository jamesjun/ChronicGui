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

fParfor = 1;
tOffset = 0;
tDuration = 120;
spkLim = [-8, 12];
viDay = [3:10, 12:21];
viShank = [1:4];
freqLim = [500 11875];  %[300 3000] [300 6000] [500 11875] 
maxAmp = 1000;

warning off;
if fParfor
    delete(gcp);
    parpool(4);
end
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

ANM282996.plotClusters('maxAmp', 100, 'fShowWaveform', 1, 'fPlot', 1, ...
    'viDay', 18, 'viShank', 3);

%% make a stacked plot of the number of clusters


tic;
obj = obj.cluster('fPlot', 1, 'vcFet', 'peak', 'vcDist', 'euclidean', ...
    'maxAmp', 1000, 'fNormFet', 0, 'fParfor', fParfor, 'fGinput', 0, ...
    'viDay', 21, 'viShank', 1);
% obj.plotClusters('maxAmp', maxAmp);


%%
viShank = 1;
tic
obj = Animal('ANM282996');
obj = obj.getFet('viDay', 21, 'readDuration', [0 32], 'fCov', 1, ...
    'maxAmp', 1000, 'fUseSubThresh', 0, 'freqLim', [300 6000], ... %500 11875       300 6000
    'fMeanSubt', 1, 'thresh', [2 4], 'viShank', viShank, 'vcPeak', 'Vpp', ...
    'fSpkWav', 1, 'fPlot', 1, 'spkLim', [-8, 12], 'fParfor', 0, 'nInterp', 4);
toc
obj = obj.cluster('viDay', 21, 'viShank', viShank, 'vcFet', 'peak', ...
    'fAskUser', 1, 'vcDist', 'euclidean', 'fPlot', 1);
