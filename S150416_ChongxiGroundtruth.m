% detect intracell peak

iChInt = 3; %intracell chan number.
viChExt = [1,2,4];
nInterp = 1;

% vcFilename = 'E:\EC\MladenTritrodePatchData\03012013\';
% vcFilename = 'E:\EC\MladenTritrodePatchData\01092013\';
% vcFilename = 'E:\EC\MladenTritrodePatchData\01092013\bp2012_0113.abf';
vcFilename = '/Users/junj10/Dropbox (HHMI)/MladenTritrodePatchData/01092013/bp2012_0113.abf';

[mrWav, Sfile] = importAbf(vcFilename, 'freqLim', [300 .95*10000], 'fMerge', 0, 'fSpont', 1);
if nInterp>1
    mrWav = interp1(1:size(mrWav,1), mrWav, ...
        1:1/nInterp:size(mrWav,1), 'spline');
    Sfile.sRateHz = Sfile.sRateHz * nInterp;
end

%%
% medNeo = median(abs(vrNeo));

viSpk = peakDetector(mrWav(:,iChInt), 'fPlot', 1, 'peakThresh', 0, 'minInterval', 20);

figure; plot(mrWav(:,iChInt));
hold on; plot(viSpk, mrWav(viSpk, iChInt), 'ro');
title('Intracell trace');
set(gcf, 'Name', vcFilename);


% vrNeo = calcNeo(mrWav(:,iChInt));
% viSpkNeo = peakDetector(vrNeo, 'fPlot', 1, 'peakThresh', 60);

% Intracell build spike table and show
% viSpkTrig = viSpk; %or viSpk for peak
%timeLim = [-1/4 1/4]*32-12; % [-1 2]*32;
timeLim = [-23, 8]*nInterp;
trSpkWav = waveformTrig(mrWav(:, [iChInt, viChExt]), viSpk, timeLim);
P.csTitles = {'Int', 'EC1', 'EC2', 'EC3'};
P.grid = 'on';
figure; trPlot(trSpkWav, P);

% vrWavIntDiff = -differentiate(mrWav(:,iChInt));
% trSpkWav1 = trSpkWav;
% trSpkWav1(:,1,:) = waveformTrig(vrWavIntDiff, viSpkTrig, timeLim);
% P.csTitles = {'Int diff', 'EC1', 'EC2', 'EC3'};
% figure; plotSpkWav(trSpkWav1, P);
% iSpk=0;

% trSpkWav = alignSpkWav(trSpkWav, 'iMax', -timeLim(1)+1, 'viChan', iChInt);
% figure; plotSpkWav(trSpkWav, P);

%%  Extracell spike table

timeLim = [-8, 23]*nInterp; % [-1 2]*32;
extSpkThresh = qqThresh(mrWav(:,2:4));
fprintf('extSpkThresh=%f\n', extSpkThresh);
viSpkExt = peakDetector(-sum(mrWav(:,viChExt),2), 'fPlot', 0, 'peakThresh', extSpkThresh, 'minInterval', 20);
[trSpkWavExt, viSpkExt] = waveformTrig(mrWav(:,[iChInt, viChExt]), viSpkExt, timeLim);

figure; trPlot(trSpkWavExt); title('EC min');

%trSpkWavExt1 = alignSpkWav(trSpkWavExt, 'iMax', -timeLim(1)+1, 'viChan', viChExt);
%figure; plotSpkWav(trSpkWavExt1); title('EC neo');


%%
% nLag = 4;
% fMix = 0;
% mrFetInt = buildXcvFet(trSpkWav(:,2:4,:), 'fMix', fMix, 'nLag', nLag);
% vrDistInt=pdist(mrFetInt', 'cosine');
% median(vrDistInt)

% %%
% figure; cdfplot(vrDistInt); xlabel('Dist int');
% %
% mrFetExt = buildXcvFet(trSpkWavExt(:,2:4,:), 'fMix', fMix, 'nLag', nLag);
% vrDistExt=pdist(mrFetExt', 'cosine');
% figure; cdfplot(vrDistExt); xlabel('Dist ext');
% nanmedian(vrDistExt) / nanmedian(vrDistInt)

%% characterize detection success
vcFet = 'pca';
nLags = 3;
nPca = 9;

switch lower(vcFet)
    case 'vpp' %70%
        mrFetExt = fetVpp(trSpkWavExt(:,2:4,:), 'fZccore', 1);
        vcDist = 'cosine';
    case 'xcov_vpp'
        mrFetExt = [fetXcovPair(trSpkWavExt, 'nLags', nLags, 'fZscore', 1); ...
                        fetVpp(trSpkWavExt(:,2:4,:), 'fZccore', 1)];
        vcDist = 'cosine';
    case 'xcov_pcamultivpp'
        mrFetExt = [fetXcovPair(trSpkWavExt, 'nLags', nLags, 'fZscore', 1); ...
                        fetPcaMultiVpp(trSpkWavExt(:,2:4,:), 6, 'fZccore', 1)];
        vcDist = 'cosine';
    case 'xcov_pca'
        mrFetExt = [fetXcovPair(trSpkWavExt, 'nLags', nLags, 'fZscore', 1); ...
                        zscoreMtx(getWavPca(trSpkWavExt(:,2:4,:), nLags))];
        vcDist = 'cosine';
    case 'pca'
        mrFetExt = getWavPca(trSpkWavExt(:,2:4,:), 3);
        vcDist = 'cosine';
    case 'pcadiff'
        mrFetExt = getWavPca(diffPair(trSpkWavExt(:,2:4,:)), 3);
        vcDist = 'cosine';
    case 'pcamulti'
        mrFetExt = pcaMulti(trSpkWavExt(:,2:4,:), nPca);
        vcDist = 'mahal';
    case 'pcavpp'
        mrFetExt = fetPcaVpp(trSpkWavExt(:,2:4,:), 4, 'fZscore', 1, 'hFunc', @(x)abs(min(x)));
        vcDist = 'cosine';
    case 'pcamultivpp'
        mrFetExt = fetPcaMultiVpp(trSpkWavExt(:,2:4,:), 6, 'fZscore', 1, 'hFunc',  []);
        vcDist = 'cosine';
    case 'pcaxcov'
        P = struct('nLags', nLags, 'fZscore', 0);
        P.cvChanPair = {[2,3], [2,4], [3,4]};
        mrFetExt = fetXcovPair(pcaClean(trSpkWavExt, 'viChan', 2:4, 'nPca', nPca), P);
        vcDist = 'cosine';
    case 'xcov'
        P = struct('nLags', nLags, 'fZscore', 0);
        P.cvChanPair = {[2,3], [2,4], [3,4]};
        mrFetExt = fetXcovPair(trSpkWavExt, P);
        vcDist = 'cosine';
    case 'pcaxcv'
        mrFet = buildXcvFet(pcaClean(trSpkWavExt(:,2:4,:), 'nPca', nPca), 'nLag', nLags);
        vcDist = 'cosine';
    case 'xcv'
        mrFet = buildXcvFet(trSpkWavExt(:,2:4,:), 'nLag', nLags);
        vcDist = 'cosine';
end
%mrFetInt = fetXcovPair(trSpkWav, 'nLags', nLags);

Sclu = clusterScience(mrFetExt, 'vcDist', vcDist, 'fAskUser', 1, 'subsample', 1, 'percent', .2);
% Sclu.cl = KCluster(mrFetExt');

%
vrFracInt = [];
vrRat = [];
vnSpk = [];
nIntSpkTot = sum(toVec(trSpkWav(round(end/2),1,:) > -20));
vnIntSpkHit = [];
% vrRef = std(pdist([mrFetInt], vcDist));
for iClu=1:max(Sclu.cl)
    vl = Sclu.cl==iClu;
    vnSpk(iClu) = sum(vl);
    %vrRat(iClu+1) = std(pdist([mrFetExt(:, vl), mrFetInt]', vcDist));
    vnIntSpkHit(iClu) = sum(toVec(trSpkWavExt(round(end/2),1,Sclu.cl == iClu) > -20));
end

disp(vnSpk)
%vrRatSdFet = vrRef ./ vrRat; %higher better
%disp(vrRatSdFet)
[nIntSpkHit, iCluMax] = max(vnIntSpkHit);
disp('hit');
disp(vnIntSpkHit/nIntSpkTot);
disp('prob true');
disp(vnIntSpkHit./vnSpk);