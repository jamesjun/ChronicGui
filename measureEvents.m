function vrMeas = measureEvents(S, P)
if ~isfield(P, 'fDiffPair'), P.fDiffPair = 0; end

vrQ = quantile(S.vrEvtAmp, [.9, .5]);
rate = numel(S.vrEvtAmp) / S.tLoaded;
rate90 = sum(S.vrEvtAmp >= vrQ(1)) / S.tLoaded;

N = S.vnEvtNChan; %(S.vrEvtAmp >= vrQ(1));
if P.fDiffPair
    N = ceil(N / 2);
end
vrCnt = [sum(N==1), sum(N==2), sum(N==3), sum(N>=4)] / S.tLoaded;

vrMeas = [vrQ(1), vrQ(2), rate, rate90, vrCnt];
