function mrTop = wavtop(tr, nTop)
if nargin < 2
	nTop = 5;
end
nSpks = size(tr,3);
nChans = size(tr,2);
mrTop = zeros(nTop*nChans, nSpks);
figure;
AX = [];
viRange = 1:nTop;
for iChan = 1:nChans
    mr1 = tr2mr(tr,iChan);
    vr0 = median(mr1,2);
    AX(end+1) = subplot(nChans,1,iChan);
    plot(vr0);
    [~, viSlt] = sort(abs(vr0), 'descend');
    mrTop(viRange,:) = mr1(viSlt(1:nTop),:);
    viRange = viRange + nTop;
end

linkaxes(AX,'xy');