function mrPcaVpp = fetPcaVpp(tr, nPca, varargin)
P = funcDefStr(funcInStr(varargin{:}), 'fZscore', 1, 'hFunc', []);

if nargin < 2, nPca = 4; end

nWav = size(tr,1);
nChans = size(tr,2);
nTrans = size(tr,3);
mrPcaVpp = zeros([nChans, nTrans], 'single');
% tic
%viRange = 1:nPca;
for iChan = 1:nChans
    mr = tr2mr(tr, iChan);
    [mrWav1, mrPca1, vrLat] = princomp(mr);
    mrSpkWav1 = mrPca1(:, 1:nPca) * mrWav1(:,1:nPca)';
    %mrSpkWav1 = mrWav1(:,1:nPca) * bsxfun(@times, mrPca1(:, 1:nPca), vrLat(1:nPca)')';
    if ~isempty(P.hFunc)
        mrPcaVpp(iChan,:) = P.hFunc(mrSpkWav1);
    else
        mrPcaVpp(iChan,:) = max(mrSpkWav1)-min(mrSpkWav1);
    end
end
% toc

if P.fZscore
    mrPcaVpp = zscoreMtx(mrPcaVpp);
end
