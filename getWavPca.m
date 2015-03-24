function mrPca = getWavPca(tr, nPca)
if nargin < 2, nPca = 3; end

nWav = size(tr,1);
nChans = size(tr,2);
nTrans = size(tr,3);
mrPca = zeros([nPca*nChans, nTrans], 'single');
% tic
viRange = 1:nPca;
for iChan = 1:nChans
    mrPca1 = princomp(reshape(tr(:, iChan, :), [nWav, nTrans]), 'econ');
    mrPca(viRange, :) = mrPca1(:, 1:nPca)';
    viRange = viRange + nPca;
end
% toc

