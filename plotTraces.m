function plotTraces(mrWav, varargin)
P = funcDefStr(funcInStr(varargin{:}), ...
    'tlim', [], 'sRateHz', 25000, 'maxAmp', 1000, 'nlim', [], ...
    'LineStyle', '-');
if isempty(P.nlim)
    if ~isempty(P.tlim) && ~isempty(P.sRateHz)
        nlim = ceil(P.tlim * P.sRateHz);
        nlim(1) = max(1, nlim(1));
        nlim(2) = min(size(mrWav,1), nlim(2));
    else
        nlim = [1,size(mrWav,1)];
    end
else
    nlim = P.nlim;
end
mrWav = mrWav(nlim(1):nlim(2), :);
nChans = size(mrWav,2);

% figure;
vrT = (nlim(1):nlim(2)) / P.sRateHz;

colormap jet;   set(gca, 'Color', 'k');
mrColor = jet(nChans);
hold on;
for iChan = 1:nChans
    plot(vrT, linmap(mrWav(:,iChan), [-1, 1]*P.maxAmp, [-1, 1]/2) + iChan, ...
        'color', mrColor(iChan,:), 'LineStyle', P.LineStyle);
end
xlabel('Time (sec)');
set(gca, 'YTick', 1:nChans);
ylabel('Chan. #');
xlim(vrT([1, end]));