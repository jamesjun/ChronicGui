function [ Y, Y1, IDX] = calcBinnedMean( X, binsize, func)
%CALCBINNEDMEAN Summary of this function goes here
%   length(Y) = floor(numel(X)/binsize)
%   length(Y1) = length(X), Y1 repeats and preserves the length, returns a
%   column vector for Y and Y1 for any vector format of X
if nargin < 3
    func = @mean;
end

if size(X,1) > 1 && size(X,2) > 1
    % matrix calculation
    nbins = floor(size(X,1)/binsize);
    nCols = size(X,2);
    Y = zeros(nbins, nCols);
    for iCol = 1:nCols
        Y(:,iCol) = calcBinnedMean(X(:,iCol), binsize, func);
    end
    return;
end
nbins = floor(numel(X)/binsize);

Y = func(reshape(X(1:binsize*nbins), binsize ,[]))'; %make it a column
IDX = (0:(numel(Y)-1)) * binsize + round(binsize/2);

if nargout > 1
    Y1 = imresize(Y, [binsize*nbins, 1],'nearest');
    nExcess = numel(X) - numel(Y1);
    if nExcess > 0
        Y1(end+1:end+nExcess) = Y1(end);  %repeat the last value
    end
end

end