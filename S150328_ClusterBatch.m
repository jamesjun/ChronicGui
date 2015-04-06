% %% single day plot. only plot shank 1 & 2

fParfor = 1;
tOffset = 0;
tDuration = 900; % 3513s to process
% viDay = setdiff([1:21], [4 6 8 9 18]);
viDay = [];
viShank = 1:4;
freqLim = [300 6000];
vcAnimal = 'ANM282996';
fSave = 1;
% spkLim = [-12, 16];
spkLim = [-8, 12];
nPadding = 8;
fPlot = 0;

%%
viDay = 21; viShank = 2; fParfor = 0; fSave = 0; tDuration = 100; tOffset=0; fPlot = 1;
% if ~exist('obj', 'var')
    obj = Animal(vcAnimal);
% end
tic
obj = obj.getFet('viDay', viDay, 'readDuration', [0 tDuration]+tOffset, ...
    'maxAmp', 1000, 'fUseSubThresh', 1, 'freqLim', freqLim, ... %500 11875       300 6000
    'fMeanSubt', 0, 'thresh', [2 4], 'viShank', viShank, 'vcPeak', 'min', ...
    'fPlot', fPlot, 'spkLim', spkLim, 'fParfor', fParfor, ...
    'nInterp', 4, 'nPadding', nPadding, 'keepFraction', .5, 'fCluster', 1, ...
    'vcFet', '@(x)vpp(x)', 'fLog', 0, 'fDiffPair', 1, ...
    'fAskUser', 0, 'vcDist', 'euclidean', 'fShowWaveform', 0, ...
    'SIGMA_FACTOR', 6, 'MAX_RHO_RATIO', 1/8, 'fHalo', 0, ...
    'fCleanClu', 1, 'spkRemoveZscore', 3, 'fNormFet', 0, 'funcFet', [], ...
    'nSpkMax', 100);
toc %32 sec for 300 sec data, 175.093821s for 600s data.
if fSave
    eval(sprintf('%s = obj;', vcAnimal));
    eval(sprintf('save %s_%d %s -v7.3;', vcAnimal, tDuration, vcAnimal));
end

%% simple
obj = Animal(vcAnimal, 'readDuration', [0 100], 'viDay', 21, 'viShank', 1);
obj = obj.getFet('fCluster', 1, 'fPlot', 0, 'fDiffPair', 1);
obj.plotBarClu();

%%
% obj = obj.cluster('fDiffPair', 1);

%%
% recluster, refine
% tic
% obj = obj.cluster('fPlot', 1, 'fAskUser', 1, ...
%     'MAX_RHO_RATIO', 1/4, 'SIGMA_FACTOR' ,6,...
%     'maxAmpl', 800, 'fLog', 0, 'vcFet', 'vmaxstd', 'funcFet', [], ...
%     'fShowWaveform', 1, 'fReclust', 1, 'spkRemoveZscore', 3, ...
%     'vcDist', 'euclidean');
% toc

%%
% obj.plotClusters('viDay', viDay, 'viShank', viShank, 'maxAmp', 1000, ...
%     'fShowWaveform', 1, 'nSpkMax', 100);
% obj.plotBarClu();
