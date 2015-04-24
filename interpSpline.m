function mrWav = interpSpline(mrWav, nInterp)
if nInterp == 1
    return;
end

if iscell(mrWav)
    for i=1:numel(mrWav)
        mrWav{i} = interpSpline(mrWav{i}, nInterp);
    end
    return;
end

mrWav = interp1(1:size(mrWav,1), mrWav, ...
    1:1/nInterp:size(mrWav,1), 'spline');
end %func