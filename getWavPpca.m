function mrPca = getWavPpca(tr, varargin)

P = funcDefStr(funcInStr(varargin{:}), ...
    'fLatent', 0, 'nPca', 3, 'nPadding', 0, 'fPcaMulti', 0, 'trimLim', []);
nSamples = size(tr,1);
nChans = size(tr,2);
nSpks = size(tr,3);

if ~isempty(P.trimLim);
    tr = trimSpkWav(tr, P.trimLim);
else
    tr = tr(P.nPadding+1:nSamples-P.nPadding, :, :);
end
if P.fPcaMulti
    [~, mrPca, vrLat] = ppca(tr2mr(tr)', P.nPca*nChans);
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
        [~, mrPca1, vrLat] = ppca( ...
            reshape(double(tr(:, iChan, :)), [size(tr,1), nSpks])', P.nPca);
    %     vrLat = vrLat / sum(vrLat); %norm
        if P.fLatent
            mrPca(viRange, :) = bsxfun(@times, mrPca1', vrLat(1:P.nPca));
        else
            mrPca(viRange, :) = mrPca1';
        end
        viRange = viRange + P.nPca;
    end
end