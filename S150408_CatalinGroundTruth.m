% S150408_Catalin


%% load and preprocess
tlim = []; %time range to analyze, 2840s max
fFibo = 1;
flim = [50, .95*5000];
%flim = [50, 3000]; %highpass
nInterp = 1;
maxAmp = 2000;
fCorr = 0;
tPlot = [0 1];
fDiffPair = 0;
viChan = (1:8);
thresh = 400; %QQ criteria
vcFilename = 'James_ThursdayTest_extracellular.tsf';
% vcFilename = 'James_in-vitro_extracellular_traces.tsf';
vcOutFilename = sprintf('%s.csv', vcFilename(1:end-4));

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
mrWav = mrWav0(nlim(1):nlim(2), viChan); %trim data
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
    if isinf(flim(2))
        vcFilt = 'high'; flim1 = flim(1);
    else vcFilt = 'bandpass'; flim1 = flim;
    end
    [vrFiltB, vrFiltA] = butter(4, flim1 / Sfile.sRateHz/nInterp * 2, vcFilt); 
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
    'thresh', [], 'maxAmp', maxAmp, 'nSpkMax', 100, 'spkLim', [-1,3]*16*nInterp, ...
    'funcFet', [], 'vcDist', 'cosine', 'percent', .2, 'spkRemoveZscore', 3, ...
    'iCluNoise', 0, 'fNormFet', 0, 'fZscore', 0, 'vcFet', 'pcaxcov', 'nPcaPerChan', 3, ...
    'vcFetMeas', 'vpp', 'slopeLim', [-8,16], 'mrSiteLoc', Sfile.Siteloc(:,viChan));
[S, P] = buildSpikeTable(mrWav, P);
%
P.fAskUser =  1;
tic
[S, P] = cluster1(S, P);
P.viClu = S.Sclu.cl;
toc

%
P.ampLim = [-5 5];
figure; plotTetClu(S.mrFet, P);
figure; plotWaveform(S, P);

vr = S.trSpkWav(17,:,:); %nPadding 
qqThresh = median(abs(vr(:)))* (5/.6745);
fprintf('QQ thresh: %0.1f uV\n', qqThresh);

% save
vcOutFilename1= [vcOutFilename(1:end-4), '_' P.vcFet, '.csv'];
vcOutFilename2= [vcOutFilename(1:end-4), '_' P.vcFet, '.mat'];
viTime = ceil(S.vrTime(:)*Sfile.sRateHz*nInterp)-1;
dlmwrite(vcOutFilename1, [S.vrTime(:), S.Sclu.cl],'precision','%.6f');
save(vcOutFilename2, 'S', 'P');
