function n = corrTime(x)
nmax = 100;
[cov_ww] = xcov(x(:),nmax,'coeff');
cov_ww = cov_ww((end+1)/2:end);
n = find(cov_ww < 0, 1, 'first');
figure; plot(cov_ww); title('corrTime');