function vr = vmaxsqr(mr)
[~, imax] = max(sum(mr.^2));
vr = mr(imax, :);