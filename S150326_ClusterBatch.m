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

%%
% viDay = 21; viShank = 1; fParfor = 0; fSave = 0;

obj = Animal(vcAnimal);
tic
obj = obj.getFet('viDay', viDay, 'readDuration', [0 tDuration]+tOffset, 'fCov', 0, ...
    'maxAmp', 1000, 'fUseSubThresh', 1, 'freqLim', freqLim, ... %500 11875       300 6000
    'fMeanSubt', 1, 'thresh', [2 4], 'viShank', viShank, 'vcPeak', 'Vpp', ...
    'fSpkWav', 1, 'fPlot', 0, 'spkLim', spkLim, 'fParfor', fParfor, 'nInterp', 4);
toc
tic
obj = obj.cluster('viDay', viDay, 'viShank', viShank, 'vcFet', 'peak', ...
    'fAskUser', 0, 'vcDist', 'euclidean', 'fPlot', 0, 'fShowWaveform', 0, ...
    'maxAmp', 1000, 'fParfor', fParfor, 'SIGMA_FACTOR', 4, 'fHalo', 0, ...
    'fCleanClu', 1);
toc
if fSave
    eval(sprintf('%s = obj;', vcAnimal));
    eval(sprintf('save %s %s;', vcAnimal, vcAnimal));
end
%24 sec for 120 sec data
%%
% obj.plotClusters('viDay', viDay, 'viShank', 1, 'maxAmp', 1000, 'fShowWaveform', 1);
obj.plotBarClu();
