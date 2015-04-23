% groundTruth class


gnd=Groundtruth('spont', 'fMerge', 1, 'freqLim', [300 9500], 'nInterp', 1, 'fPlot',0, 'vcClu', 'klustakwik', 'nPadding', 10);
gnd=gnd.import();
gnd=gnd.detect('vcDetect', 'min', 'fPlot', 0, 'qqFactor', 4);

%%
% gnd=gnd.test('vcFet', 'pca', 'fLatent', 0, 'fDiffPair', 0, 'nPca', 3, 'fNormFet', 0, ...
%     'vcClu', 'klustakwik', 'vcDist', 'cosine', 'fAlign', 10);
%% pcamulti works the best so far
P = struct('alignPower', 1, 'fSquare', 0, 'fPhaseMag', 1, 'fRescale', 1, 'fDiffPair', 0, 'fAlign', 1, ...
    'trimLim', [], 'diffOrder', 7, 'fPlot', 1,  ...
    'nTrim', 4, 'fSmooth', 0, 'fPcaMulti', 1, ...
     'vcFet', 'pca', 'nPca', 3, 'fLatent', 1, 'fNormFet', 0);
gnd=gnd.test(P);
gnd=gnd.test(P); %second run
%%

%%
% gnd=gnd.cluster('vcClu', 'klustakwik');
% gnd.eval;
%%
% vcFilename = 'E:\EC\MladenTritrodePatchData\01092013\';
% vcFilename = 'E:\EC\MladenTritrodePatchData\01092013\bp2012_0113.abf';