function plotCluRaster(vrTime, viClu)
vrTime = vrTime(:)';
nClu = max(viClu);

mrColor = [.5 .5 .5; jet(nClu-1)];
% mrColor(1,:) = .5; %grey
hold on;
% colormap jet;

for iClu = 1:nClu
    viSpk = find(viClu == iClu);
    vrX = repmat(vrTime(viSpk), [2 1]);
    vrY = bsxfun(@plus, iClu*ones(1, numel(viSpk)), [-.5; .5]);
    plot(vrX, vrY, 'Color', mrColor(iClu,:));
end
set(gca, 'Color', 'k');
axis([0 ceil(max(vrTime)), .5 nClu+.5]);
xlabel('time (sec)');