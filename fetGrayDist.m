function [mnSum, mnDiff] = fetGrayDist(vrY)
%http://www.nature.com/nmeth/journal/v11/n7/extref/nmeth.2994-S1.pdf
% polavieja nature 2014 apper algorithm

nChans = size(vrY,2);
nSamples = size(vrY,1);

vrY = abs(vrY(:));
viT = repmat((1:nSamples)', [nChans, 1]);

vrDiff = pdist(vrY, @(x,y)abs(bsxfun(@minus, y,x)));
vrSum = pdist(vrY, @(x,y)bsxfun(@plus, y,x));
vrDt = pdist(viT, @(x,y)abs(bsxfun(@minus, y,x)));

mnSum = hist3([vrDt(:), vrSum(:)], 'Edges', {1:2:max(vrDt), 0:.01:.16});
mnDiff = hist3([vrDt(:), vrDiff(:)], 'Edges', {1:2:max(vrDt), 0:.01:.16});
if nargout == 0
    figure; subplot 121; imagesc(mnSum);
    subplot 122; imagesc(mnDiff);
end