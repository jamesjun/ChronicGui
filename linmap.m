function vr = linmap(vr, lim1, lim2, fSat)
if nargin< 4
    fSat = 0;
end

if fSat
    vr(vr>lim1(2)) = lim1(2);
    vr(vr<lim1(1)) = lim1(1);
end
vr = interp1(lim1, lim2, vr, 'linear', 'extrap');