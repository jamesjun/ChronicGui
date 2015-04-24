function mrTop = wavtopMulti(tr, nTop)
if nargin < 2
	nTop = 5;
end
nSpks = size(tr,3);
nChans = size(tr,2);
mrTop = zeros(nTop*nChans, nSpks);

viRange = 1:nTop;
mr0 = reshape(tr, size(tr,1),[]);
vr0 = median(mr0,2);
[~, viSlt] = sort(vr0, 'ascend'); %get minmum 
viSlt1 = viSlt(1:nTop);
for iChan = 1:nChans
    mr1 = tr2mr(tr,iChan);    
    mrTop(viRange,:) = mr1(viSlt1,:);
    viRange = viRange + nTop;
end

figure; hold on;
plot(vr0);
plot(viSlt1, vr0(viSlt1), 'ro');
% linkaxes(AX,'xy');