function mrPcaVpp = fetPcaAmpWid(tr, nPca, varargin)
P = funcDefStr(funcInStr(varargin{:}), 'fZscore', 1, 'hFunc', [], 'nInterp', 1);

if nargin < 2, nPca = 4; end

nSamples = size(tr,1);
nChans = size(tr,2);
nTrans = size(tr,3);
mrAmp = zeros([nChans, nTrans], 'like', tr);
mrWid = zeros([nChans, nTrans], 'like', tr);

% tic
%viRange = 1:nPca;
for iChan = 1:nChans
    mr = tr2mr(tr, iChan);
    [mrWav1, mrPca1, vrLat] = princomp(mr);
    mrSpkWav1 = mrPca1(:, 1:nPca) * mrWav1(:,1:nPca)';
    if P.nInterp>1
        mrSpkWav1 = interp1(1:nSamples, mrSpkWav1, ...
            1:1/nInterp:nSamples, 'spline');
    end
    [vrMin, viMin] = min(mrSpkWav1);
    mrAmp(iChan,:) = vrMin; %amp determined
    
    vrThresh = vrMin / exp(1);
    for iSpk=1:nSpks
        
    end
    ml = bsxfun(@lt, mrSpkWav1(1:viMin,:), vrThresh);
end
% toc

if P.fZscore
    mrPcaVpp = zscoreMtx(mrPcaVpp);
end
