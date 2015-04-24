function mrPcaVpp = fetPcaMultiVpp(tr, nPca, varargin)
%multi-chan pca

P = funcDefStr(funcInStr(varargin{:}), 'fZscore', 1, 'hFunc', []);
nSamples = size(tr,1);
nChans = size(tr,2);
nSpks = size(tr,3);
if isempty(P.hFunc)
    P.hFunc = @(x)max(x)-min(x);
end

if nargin < 2, nPca = 4; end


mr = reshape(tr, size(tr,1)*size(tr,2), []);
    
[mrWav1, mrPca1, vrLat] = princomp(mr);
mrSpkWav1 = mrPca1(:, 1:nPca) * mrWav1(:,1:nPca)';
mrSpkWav1 = reshape(mrSpkWav1, nSamples, []);
mrPcaVpp = reshape(P.hFunc(mrSpkWav1), nChans,[]);

if P.fZscore
    mrPcaVpp = zscoreMtx(mrPcaVpp);
end
