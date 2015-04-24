function viMin = detectMin(mrWav, varargin)
P = funcDefStr(funcInStr(varargin{:}), 'fPlot', 1, 'thresh', [], 'minInterval', [], ...
    'fSum', 1, 'sRateHz', 10000, 'fAlign',0, 'qqFactor', 5);

if isempty(P.thresh)
    P.thresh = -qqThresh(mrWav, P.qqFactor);
end
vrWav=sum(mrWav,2);
if P.fAlign
    vrWavSq = sum(mrWav.^2,2);
end
if P.fSum
    vlData = vrWav < P.thresh;
else
    mlData = bsxfun(@lt, mrWav, P.thresh)'; %widen the mask
    vlData = logical(any(mlData));
    % convolve vlData for merging purpose
    nOneMs = round(.0005 * P.sRateHz);
    vlData = logical(conv(double(vlData), ones(nOneMs,1), 'same'));
end

[viUp, viDn, nSpks] = findTrans(vlData);

viMin = zeros(size(viUp));
for iSpk=1:nSpks
    if P.fAlign
        [~, iMin] = max(vrWavSq(viUp(iSpk):viDn(iSpk)));
    else
        [~, iMin] = min(vrWav(viUp(iSpk):viDn(iSpk)));
    end
    viMin(iSpk) = iMin + viUp(iSpk) - 1;
end

if ~isempty(P.minInterval)
    while 1
        iKill = find(diff(viMin) < P.minInterval, 1, 'first');
        if isempty(iKill), break; end
        viMin(iKill+1) = [];
    end
end

if P.fPlot
    figure;
    plot(vrWav, 'k-');
    hold on;
    plot(viMin, vrWav(viMin), 'ro');
    if ~isempty(P.thresh)
        plot([1, numel(vrWav)], P.thresh*[1 1], 'r-');
    end
end


