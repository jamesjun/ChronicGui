function tr = trimSpkWav(tr, nLim)
% trims the spiketable at the median waveform across channel

if nargin < 2
	nLim = [-5, 5];
end
tr0=tr;
mr0 = reshape(tr, size(tr,1),[]);
vr0 = median(mr0,2);
[~, iMin] = max(abs(vr0));
viRange = (nLim(1):nLim(end)) + iMin;
viRange = mod(viRange-1, size(tr,1)) + 1;
tr = tr(viRange,:,:);
vrX = (1:size(tr0,1)) - iMin;

figure; 
subplot 211;
hold on;
plot(vrX, vr0);
plot(vrX(viRange), vr0(viRange), 'ro');
plot(0*[1 1], get(gca, 'YLim'), 'r-');
ylabel('median');

subplot 212;
hold on;
% mrCv = sqrt(mean(tr0.^2,3) ./ std(tr0.^2,1,3));
vrY2 = mean(std(tr0,1,3),2);
stem(vrX, vrY2); ylabel('<SD>');
plot(0*[1 1], get(gca, 'YLim'), 'r-');
plot(vrX(viRange), vrY2(viRange), 'ro');