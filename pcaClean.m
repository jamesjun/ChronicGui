function [tr, vrLat] = pcaClean(tr, varargin)
P = funcDefStr(funcInStr(varargin{:}), 'viChan', [], 'pcaThresh', [], 'nPcaPerChan', 3, 'nPca', []);
%Pca waveform cleanup based on multichannel

nSamples = size(tr,1);
nChans = size(tr,2);
nSpks = size(tr,3);

if isempty(P.viChan), P.viChan = 1:nChans; end
    
[mrWav1, mrPca1, vrLat] = ...
    princomp(reshape(tr(:,P.viChan,:), nSamples*numel(P.viChan), nSpks));

if ~isempty(P.nPca);
    nPca = P.nPca;
elseif ~isempty(P.pcaThresh)
    nPca = find(cumsum(vrLat)/sum(vrLat) > P.pcaThresh, 1, 'first');
elseif ~isempty(P.nPcaPerChan)
    nPca = P.nPcaPerChan * numel(P.viChan);
else
    error('pcaClean-specify nPca');
end
fprintf('pcaClean: nPca=%d\n', nPca);
figure; plot(cumsum(vrLat)/sum(vrLat)); ylabel('Pct var captured'); xlabel('# pca'); set(gca, 'XScale', 'log');

mrSpkWav1 = mrPca1(:, 1:nPca) * mrWav1(:,1:nPca)';
tr(:,P.viChan,:) = reshape(mrSpkWav1, nSamples, numel(P.viChan), nSpks);

