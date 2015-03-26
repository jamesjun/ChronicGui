% %% single day plot. only plot shank 1 & 2

fParfor = 1;
tOffset = 0;
tDuration = 120;
spkLim = [-8, 12];
viDay = [3:10, 12:21];
viShank = [1:4];
freqLim = [300 6000];


%%
tic
obj = Animal('ANM282996');
obj = obj.getFet('viDay', viDay, 'readDuration', [0 tDuration]+tOffset, 'fCov', 0, ...
    'maxAmp', 1000, 'fUseSubThresh', 1, 'freqLim', freqLim, ... %500 11875       300 6000
    'fMeanSubt', 1, 'thresh', [2 4], 'viShank', viShank, 'vcPeak', 'Vpp', ...
    'fSpkWav', 1, 'fPlot', 0, 'spkLim', [-8, 12], 'fParfor', fParfor, 'nInterp', 4);
toc
obj = obj.cluster('viDay', viDay, 'viShank', viShank, 'vcFet', 'peak', ...
    'fAskUser', 0, 'vcDist', 'euclidean', 'fPlot', 0, 'fShowWaveform', 0, ...
    'maxAmp', 1000, 'fParfor', fParfor);

ANM282996 = obj;
save ANM282996 ANM282996;

%%
% obj.plotClusters('viDay', 21, 'viShank', viShank, 'maxAmp', 1000, 'fShowWaveform', 1);