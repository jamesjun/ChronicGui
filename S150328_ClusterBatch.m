% %% single day plot. only plot shank 1 & 2

fParfor = 1;
tOffset = 0;
tDuration = 900;
viDay = [1:21];
viShank = 1:4;
freqLim = [300 6000];
vcAnimal = 'ANM282996';
fSave = 1;
% spkLim = [-12, 16];
spkLim = [-8, 12];
nPadding = 8;
fPlot = 0;

%%
viDay = 20; viShank = 1; fParfor = 0; fSave = 0; tDuration = 300; fPlot = 1;

obj = Animal(vcAnimal);
tic
obj = obj.getFet('viDay', viDay, 'readDuration', [0 tDuration]+tOffset, 'fCov', 0, ...
    'maxAmp', 500, 'fUseSubThresh', 1, 'freqLim', freqLim, ... %500 11875       300 6000
    'fMeanSubt', 1, 'thresh', [2 4], 'viShank', viShank, 'vcPeak', 'Vpp', ...
    'fSpkWav', 1, 'fPlot', fPlot, 'spkLim', spkLim, 'fParfor', fParfor, ...
    'nInterp', 4, 'nPadding', nPadding, 'keepFraction', .5, 'fCluster', 0, ...
    'vcFet', 'peakmin', 'fLog', 0, ...
    'fAskUser', 0, 'vcDist', 'euclidean', 'fShowWaveform', 0, ...
    'SIGMA_FACTOR', 5, 'MAX_RHO_RATIO', 1/4, 'fHalo', 0, ...
    'fCleanClu', 1, 'spkRemoveZscore', 3, 'fNormFet', 0, 'funcFet', @(x)x.^2);
toc %32 sec for 300 sec data, 175.093821s for 600s data
if fSave
    eval(sprintf('%s = obj;', vcAnimal));
    eval(sprintf('save %s_%d %s;', vcAnimal, tDuration, vcAnimal));
end
%%
% recluster
tic
obj = obj.cluster('fPlot', 1, 'fAskUser', 0, ...
    'MAX_RHO_RATIO', 1/4, 'SIGMA_FACTOR' ,6, ...
    'maxAmpl', 500, 'fLog', 0, 'vcFet', 'peak', 'funcFet', [], ...
    'fShowWaveform', 1, 'fReclust', 1, 'spkRemoveZscore', 3, ...
    'vcDist', 'mahal');
toc

%%
% obj.plotClusters('viDay', viDay, 'viShank', viShank, 'maxAmp', 1000, 'fShowWaveform', 1);
% obj.plotBarClu();
