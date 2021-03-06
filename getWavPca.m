function mrPca = getWavPca(tr, varargin)

P = funcDefStr(funcInStr(varargin{:}), ...
    'fLatent', 0, 'nPca', 3, 'nPadding', 0, 'fPcaMulti', 0, 'trimLim', [], ...
    'pcaAlgo', 'svd');
nSamples = size(tr,1);
nChans = size(tr,2);
nSpks = size(tr,3);

if ~isempty(P.trimLim);
    tr = trimSpkWav(tr, P.trimLim);
else
    tr = tr(P.nPadding+1:nSamples-P.nPadding, :, :);
end
if P.fPcaMulti
    [~, mrPca, vrLat] = pca(tr2mr(tr)', 'NumComponents', P.nPca*nChans, 'Algorithm', P.pcaAlgo);
    if P.fLatent
        mrPca = bsxfun(@times, mrPca', vrLat(1:P.nPca*nChans)); 
    else
        mrPca = mrPca';
    end
%     if P.fLatent
%         mrPca = bsxfun(@times, mrPca(:,1:P.nPca*nChans)', vrLat(1:P.nPca*nChans)); 
%     else
%         mrPca = mrPca(:,1:P.nPca*nChans)';
%     end
else
    mrPca = zeros([P.nPca*nChans, nSpks], 'single');
    viRange = 1:P.nPca;
    for iChan = 1:nChans
        [~, mrPca1, vrLat] = pca( ...
            reshape(double(tr(:, iChan, :)), [size(tr,1), nSpks])', ...
            'NumComponents', P.nPca, 'Algorithm', P.pcaAlgo);
    %     vrLat = vrLat / sum(vrLat); %norm
        if P.fLatent
            mrPca(viRange, :) = bsxfun(@times, mrPca1', vrLat(1:P.nPca));
        else
            mrPca(viRange, :) = mrPca1';
        end
        viRange = viRange + P.nPca;
    end
end