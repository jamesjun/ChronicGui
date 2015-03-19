function vr = linmap(vr, lim1, lim2)

vr(vr>lim1(2)) = lim1(2);
vr(vr<lim1(1)) = lim1(1);

vr = interp1(lim1, lim2, vr, 'linear');