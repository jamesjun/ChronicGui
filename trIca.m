function mrPca = trIca(tr, varargin)

P = funcDefStr(funcInStr(varargin{:}), ...
    'nPca', 3, 'nPadding', 0, 'fPcaMulti', 0, 'trimLim', [], 'fPlot', 0);

nSamples = size(tr,1);
nChans = size(tr,2);
nSpks = size(tr,3);

if ~isempty(P.trimLim);
    tr = trimSpkWav(tr, P.trimLim);
else
    tr = tr(P.nPadding+1:nSamples-P.nPadding, :, :);
end
if P.fPcaMulti
    mrPca = myICA(tr2mr(tr), P.nPca*nChans, P.fPlot);
else
    mrPca = zeros([P.nPca*nChans, nSpks], 'single');
    viRange = 1:P.nPca;
    for iChan = 1:nChans
        mrPca(viRange, :) = myICA(tr2mr(tr,iChan), P.nPca, P.fPlot);
        viRange = viRange + P.nPca;
    end
end