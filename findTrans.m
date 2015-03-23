function [viUp, viDn, nTran] = findTrans(vlData)
try
    viUp = find(diff(vlData) > 0);
    viDn = find(diff(vlData) < 0);
    if viDn(1) < viUp(1), viDn(1) = []; end
    nTran = min(numel(viDn), numel(viUp));
    viUp = viUp(1:nTran);
    viDn = viDn(1:nTran);
catch
    viUp = [];
    viDn = [];
    nTran = 0;
end