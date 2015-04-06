function vr = vmaxstd(mr)
[~, imax] = max(std(mr, 1, 2));
vr = mr(imax, :);