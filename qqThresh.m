function thresh = qqThresh(mr, n)
if nargin < 2
    n=5;
end
thresh = median(abs(mr(:))) * n / 0.6745;