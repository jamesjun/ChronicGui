% %% single day plot. only plot shank 1 & 2

fParfor = 0;
tOffset = 0;
tDuration = 900;
viDay = [1:21];
viShank = 1:4;
freqLim = [300 6000];
vcAnimal = 'ANM282996';
fSave = 1;
% spkLim = [-12, 16];
spkLim = [-8, 12];
nPadding = 4;
fPlot = 0;

%%
viDay = 20; viShank = 1; fParfor = 0; fSave = 0; tDuration = 900; fPlot = 1;

obj = Animal(vcAnimal);
tic
obj = obj.getFet('viDay', viDay, 'readDuration', [0 tDuration]+tOffset, ...
    'maxAmp', 1000, 'fUseSubThresh', 1, 'freqLim', freqLim, ... %500 11875       300 6000
    'fMeanSubt', 1, 'thresh', [2 4], 'viShank', viShank, 'vcPeak', 'Vpp', ...
    'fSpkWav', 1, 'fPlot', 0, 'spkLim', spkLim, 'fParfor', fParfor, ...
    'nInterp', 4, 'nPadding', nPadding, 'keepFraction', .5, 'fCluster', 1);
toc %113s to load 900s, 90s to load 600s
tic
obj = obj.cluster('vcFet', 'peak', ...
    'fAskUser', 0, 'vcDist', 'euclidean', 'fPlot', fPlot, 'fShowWaveform', 0, ...
    'maxAmp', 1000, 'fParfor', fParfor, 'SIGMA_FACTOR', 5, 'fHalo', 0, ...
    'fCleanClu', 1, 'spkRemoveZscore', 3);
toc %32 sec for 300 sec data, 175.093821s for 600s data
if fSave
    eval(sprintf('%s = obj;', vcAnimal));
    eval(sprintf('save %s_%d %s;', vcAnimal, tDuration, vcAnimal));
end

%%
% obj.plotClusters('viDay', viDay, 'viShank', viShank, 'maxAmp', 1000, 'fShowWaveform', 1);
% obj.plotBarClu();
