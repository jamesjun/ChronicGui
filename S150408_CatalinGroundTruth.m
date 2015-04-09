% S150408_Catalin


%% load and preprocess
tlim = []; %time range to analyze, 2840s max
fFibo = 1;
flim = [50, .95*5000];
nInterp = 1;
maxAmp = 2000;
fCorr = 0;
tPlot = [0 .5];
fDiffPair = 0;
thresh = 400; %QQ criteria
vcFilename = 'James_ThursdayTest_extracellular.tsf';
% vcFilename = 'James_in-vitro_extracellular_traces.tsf';

if ~exist('mrWav0', 'var')
    [mrWav0, Sfile] = importTSF(vcFilename, ...
    'readDuration', []);
end
if isempty(tlim)
    nlim = [1, size(mrWav0,1)];
else
    nlim = tlim*Sfile.sRateHz; 
end
if isempty(flim), vcFlim = '[]'; 
else vcFlim = sprintf('%d..%d', flim(1), flim(2)); 
end
if isempty(tlim)
    tlim1 = round(nlim / Sfile.sRateHz);
    vcTlim = sprintf('%d..%d', tlim1(1), tlim1(2)); 
else
    vcTlim = sprintf('%d..%d', tlim(1), tlim(2));
end
vcTitle = sprintf('%s sec, fFibo:%d, %s Hz, 0..%d uV, fDiffPair:%d', ...
    vcTlim, fFibo, vcFlim, maxAmp, fDiffPair);
nlim(1) = max(1, nlim(1));
mrWav = mrWav0(nlim(1):nlim(2), :); %trim data
if fFibo, mrWav = filtFibo3(mrWav); end
if fDiffPair
    [mrWav, viChanPair1, viChanPair2] = diffPair(mrWav);
end
if nInterp>1
    mrWav = interp1(1:size(mrWav,1), mrWav, ...
        1:1/nInterp:size(mrWav,1), 'spline');
%     mrWav1 = mrWav;
%     mrWav = zeros(size(mrWav1,1)*nInterp, size(mrWav1,2));
%     for iChan=1:size(mrWav,2)
%         mrWav(:,iChan) = interp(mrWav1(:,iChan), nInterp);
%     end
%     clear mrWav1;
end
if ~isempty(flim)
    [vrFiltB, vrFiltA] = butter(4, flim / Sfile.sRateHz/nInterp * 2,'bandpass');    
    mrWav = filter(vrFiltB, vrFiltA, mrWav);
end
figure; plotTraces(mrWav, 'sRateHz', Sfile.sRateHz*nInterp, ...
    'maxAmp', maxAmp, 'tlim', tPlot); 
title(vcTitle);

if fCorr
    mrCorr = corr(mrWav);
    figure; imagesc(mrCorr); 
    caxis([-.2 .2]); colormap jet;
    xlabel('Chan #'); ylabel('Chan #');
    title(['Channel correlation', vcTitle]);
end


%%
P = struct('sRateHz', Sfile.sRateHz*nInterp, 'nPadding', 16, 'nInterp', 4, ...
    'thresh', [], 'maxAmp', maxAmp, 'nSpkMax', 100, 'spkLim', [-1,2]*16*nInterp, ...
    'funcFet', [], 'vcDist', 'euclidean', 'percent', .2, 'spkRemoveZscore', 3, ...
    'iCluNoise', 0);
[S, P] = buildSpikeTable(mrWav, P);
%
P.fAskUser =  1;
[S, P] = cluster1(S, P);

%
figure; plotTetClu(S.mrFet, 'maxAmp', maxAmp, 'viClu', S.Sclu.cl);
figure; plotWaveform(S, P);
fprintf('%0.1f %% of spikes clustered\n', sum(S.Sclu.cl>=1)/numel(S.vrTime)*100);