% detect intracell peak

iChInt = 3; %intracell chan number.
viChExt = [1,2,4];
nInterp = 10;

%vcFilename = 'E:\EC\MladenTritrodePatchData\01092013\bp2012_0113.abf';
vcFilename = '/Users/junj10/Dropbox (HHMI)/MladenTritrodePatchData/01092013/bp2012_0113.abf';

[mrWav, Sfile] = importAbf(vcFilename, 'freqLim', [300 6000]);
if nInterp>1
    mrWav = interp1(1:size(mrWav,1), mrWav, ...
        1:1/nInterp:size(mrWav,1), 'spline');
    Sfile.sRateHz = Sfile.sRateHz * nInterp;
end

%%
% medNeo = median(abs(vrNeo));

viSpk = peakDetector(mrWav(:,iChInt), 'fPlot', 1, 'peakThresh', 5);

figure; plot(mrWav(:,iChInt));
hold on; plot(viSpk, mrWav(viSpk, iChInt), 'ro');
title('Intracell trace');
set(gcf, 'Name', vcFilename);


vrNeo = calcNeo(mrWav(:,iChInt));
viSpkNeo = peakDetector(vrNeo, 'fPlot', 1, 'peakThresh', 60);

%% Intracell build spike table and show
viSpkTrig = viSpk; %or viSpk for peak
%timeLim = [-1/4 1/4]*32-12; % [-1 2]*32;
timeLim = [-3 0]*8;
trSpkWav = waveformTrig(mrWav(:, [iChInt, viChExt]), viSpkTrig, timeLim);
P.csTitles = {'Int', 'EC1', 'EC2', 'EC3'};
P.grid = 'on';
figure; plotSpkWav(trSpkWav, P);

vrWavIntDiff = -differentiate(mrWav(:,iChInt));
trSpkWav1 = trSpkWav;
trSpkWav1(:,1,:) = waveformTrig(vrWavIntDiff, viSpkTrig, timeLim);
P.csTitles = {'Int diff', 'EC1', 'EC2', 'EC3'};
figure; plotSpkWav(trSpkWav1, P);
iSpk=0;

%%
iChan1 = 2;
iChan2 = 3;
%figure; plotSpkWav(mrSpkWav1);
%figure; plot(mrSpkWav1(:,iChan1), mrSpkWav1(:,iChan2),'.-');

% phase shift

% figure; plot(angle(cpsd(mrSpkWav1(:,iChan1), mrSpkWav1(:,iChan2))))
%figure; plotXcov(mrSpkWav1(:,iChan1), mrSpkWav1(:,iChan2));
%figure; plot(unwrap(angle(Txy))); title('angle');
%figure; plot(abs(Txy)); title('abs');
%hold on; plot(-log(1:size(Txy)), log(abs(Txy)), '.')

%a1 = fft(mrSpkWav1(:,iChan1)); a1=a1(1:end/2);
%a2 = fft(mrSpkWav1(:,iChan2)); a2=a2(1:end/2);
%Txy = tfestimate(mrSpkWav1(:,iChan1), mrSpkWav1(:,iChan2));

%yplot = log(abs(yf./xf));
%yplot = differentiate(log(tfestimate(xf, yf)), 3);
%hold on; plot(log(1:numel(yplot)), yplot, '.-');

%hold on; plot((mrSpkWav1(:,iChan1)), (mrSpkWav1(:,iChan2)), '.-')
%hold on; plot(1:size(Txy), angle(Txy), '.-');

%% phase diagram

% detect spikes from all channels
timeLim = [-8, 23]; % [-1 2]*32;

viSpkExt = peakDetector(-sum(mrWav(:,viChExt),2), 'fPlot', 1, 'peakThresh', .1, 'minInterval', 20);
[trSpkWavExt, viSpkExt] = waveformTrig(mrWav(:,[iChInt, viChExt]), viSpkExt, timeLim);
figure; plotSpkWav(trSpkWavExt); title('EC');
%%
nLag = 4;
fMix = 0;
mrFetInt = buildXcvFet(trSpkWav(:,2:4,:), 'fMix', fMix, 'nLag', nLag);
vrDistInt=pdist(mrFetInt', vcDist);
median(vrDistInt)

%%
figure; cdfplot(vrDistInt); xlabel('Dist int');
%
mrFetExt = buildXcvFet(trSpkWavExt(:,2:4,:), 'fMix', fMix, 'nLag', nLag);
vrDistExt=pdist(mrFetExt', vcDist);
figure; cdfplot(vrDistExt); xlabel('Dist ext');
nanmedian(vrDistExt) / nanmedian(vrDistInt)

%% characterize detection success
vcFet = 'vpp';
nLags = 3;

switch lower(vcFet)
    case 'vpp' %70%
        mrFetExt = fetVpp(trSpkWavExt(:,viChExt,:), 'fZccore', 1);
        vcDist = 'seuclidean';
    case 'xcov_vpp'
        mrFetExt = [fetXcovPair(trSpkWavExt, 'nLags', nLags, 'fZscore', 1); ...
                        fetVpp(trSpkWavExt(:,viChExt,:), 'fZccore', 1)];
        vcDist = 'cosine';
    case 'xcov_pca'
        mrFetExt = [fetXcovPair(trSpkWavExt, 'nLags', nLags, 'fZscore', 1); ...
                        zscoreMtx(getWavPca(trSpkWavExt(:,viChExt,:), nLags))];
        vcDist = 'cosine';
    case 'pca'
        mrFetExt = getWavPca(trSpkWavExt(:,viChExt,:), nLags);
        
    case 'xcov'
        mrFetExt = fetXcovPair(trSpkWavExt, 'nLags', nLags, 'fZscore', 1);
        vcDist = 'cosine';
end
%mrFetInt = fetXcovPair(trSpkWav, 'nLags', nLags);

Sclu = clusterScience(mrFetExt, 'vcDist', vcDist, 'fAskUser', 1, 'subsample', 1, 'percent', 2);
%
vrFracInt = [];
vrRat = [];
vnSpk = [];

vrRef = std(pdist([mrFetInt], vcDist));
for iClu=1:max(Sclu.cl)
    vl = Sclu.cl==iClu;
    vnSpk(iClu) = sum(vl);
    %vrRat(iClu+1) = std(pdist([mrFetExt(:, vl), mrFetInt]', vcDist));
    vrFracInt(iClu) = mean(toVec(trSpkWavExt(:,1,Sclu.cl == iClu) > -20));
end
disp(vnSpk)
%vrRatSdFet = vrRef ./ vrRat; %higher better
%disp(vrRatSdFet)
disp(vrFracInt)