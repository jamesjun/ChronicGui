function plotXcov(x,y, nlags)
if nargin < 3
    nlags=10;
end
if nargin < 2
    y=x;
end
[cov_ww,lags] = xcov(x(:),y(:),nlags,'coeff');
plot(lags,cov_ww);
end