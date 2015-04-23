
load James_ThursdayTest_extracellular_vpp

%%
% iClu = 1;
n = 3;
viClu = S.Sclu.cl;
nSpks = size(S.trSpkWav,3);
nT = size(S.trSpkWav,1);
nClus = max(viClu);

viRange = (P.nPadding+1):nT;
viRangeSlope = (P.nPadding+1-P.spkLim(1)) + [-3:5];
viMin = zeros(nSpks,1);
vrMin = zeros(nSpks,1);
viMax = zeros(nSpks,1);
vrMax = zeros(nSpks,1);
% vrMin1 = zeros(nSpks,1);

viIdx = sub2ind([size(S.trSpkWav,2), nSpks], S.viChanRef, 1:nSpks);
% for iClu = 1:nClus
%     viSpk1 = find(viClu == iClu);
for iSpk = 1:nSpks
    vrSpkWav = S.trSpkWav(viRange,S.viChanRef(iSpk),iSpk);
    vrSpkWav = detrend(cumsum(vrSpkWav));
%     vrSpkWav = vrSpkWav(2:end-1).^2 - vrSpkWav(1:end-2) .* vrSpkWav(3:end);
%     vrSpkWav = differentiate(vrSpkWav,n) .* vrSpkWav;
%     vrSpkWav = vrSpkWav(-P.spkLim(1) + [-4:4]);
    vrMin(iSpk) = min(vrSpkWav);
    vrMax(iSpk) = max(vrSpkWav);
end

csStats = {'imin', 'vmin', 'imax', 'vmax', 'vpp'};
nStats = numel(csStats);
mrStats = zeros(nStats, nClus);
for iClu=1:nClus
    viSpk1 = find(viClu == iClu);
    mrStats1 = [viMin(viSpk1), abs(vrMin(viSpk1)), viMax(viSpk1), vrMax(viSpk1), vrMax(viSpk1)-vrMin(viSpk1)];
    vrMu = mean(mrStats1);
    vrSd = std(mrStats1);
    mrStats(:,iClu) =  vrMu ./ vrSd;
%     fprintf('clu=%d, cv:imin, vmin, imax, vmax, vpp\n', iClu);
end
figure;
bar(mrStats); set(gca, 'XTickLabel', csStats); 
ylabel('iCV');
ylim([0 8]);

% 
% figure; bar(vrSd
% hist(viMin, 1:nT);  title('imin');
% figure; hist(viMax, 1:nT);  title('imax');
% fprintf('n=%d, min SD=%f, Mean=%f\n', n, std(viMin), mean(viMin));
% fprintf('n=%d, max SD=%f, Mean=%f\n', n, std(viMax), mean(viMax));

%% pca 
mrSpkWav = S.trSpkWav(viRange,:,viClu==2);
mrSpkWav = reshape(mrSpkWav,size(mrSpkWav,1),[]);
[pc, score, latent] = princomp(mrSpkWav');
vrPc1 = score(:,1);
vrPc2 = score(:,2);
figure; plot(vrPc1, vrPc2, '.');
vrLatent = cumsum(latent)./sum(latent);
figure; plot(diff(vrLatent));