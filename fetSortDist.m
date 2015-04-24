function vrDist = fetSortDist(mrY)
%http://www.nature.com/nmeth/journal/v11/n7/extref/nmeth.2994-S1.pdf
% polavieja nature 2014 apper algorithm
%vnSize = size(vrY);
%

[~, miY] = sort(mrY, 'descend');
vrDist = [(miY(:,1)-miY(:,2)); (miY(:,2)-miY(:,3))];
%vrDist = pdist(miY, 'cityblock');

if nargout ==0
    mnDist = squareform(vrDist);
    figure; imagesc(mnDist);
end