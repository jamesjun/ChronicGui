% groundTruth class
dataset = 'spont2';
% dataset = 'E:\EC\MladenTritrodePatchData\01092013';
% dataset = 'E:\EC\MladenTritrodePatchData\03012013';
% dataset = 'E:\EC\MladenTritrodePatchData\01302013';

gnd=Groundtruth(dataset, 'fMerge', 1, 'freqLim', [300 9500], 'nInterp', 1, 'fPlot',0, 'nPadding', 10);
gnd=gnd.import('fSmooth', 0, 'sgOrder', 5, 'sgPoly', 4);
gnd=gnd.detect('vcDetect', 'min', 'fPlot', 0, 'qqFactor', 4);
gnd0=gnd;

%% pcamulti works the best so far
gnd=gnd0;
P = struct('alignPower', 1, 'fSquare', 0, 'fPhaseMag', 1, 'fRescale', 1, 'fDiffPair', 0, 'fAlign', 1, ...
    'trimLim', [-10 10], 'fPlot', 0, 'fPhaseSmooth', 0, 'diffOrder', 7, ...
    'vcFet', 'pca', 'nPca', 3, 'fLatent', 0, 'fPcaMulti', 1, 'fNormFet', 0, ...
    'vcClu', 'klustakwik', 'fCleanup', 1, 'fReclust', 0, 'fRealignClu', 0, 'spkRemoveZscore', [], ...
    'fAlignAfterPhase', 0, 'alignPct', .1);
gnd=gnd.test(P);
% gnd=gnd.test(P);
% gnd=gnd.reclust(P);
gnd.plotClu();

%%

%%
% gnd=gnd.cluster('vcClu', 'klustakwik');
% gnd.eval;
%% no smooth, spont
% <completeness>: 92.2, <accuracy>: 97.4, <c*a>: 89.8
% <completeness>: 93.6, <accuracy>: 96.2, <c*a>: 90.1
%% smooth, spont, no smooth second time around
% <completeness>: 91.9, <accuracy>: 96.9, <c*a>: 89.1 (smoothed twice)
%