function mrWav = interpShift(mrWav1, nInterp)

if nInterp>1
%     mrWav = interp1(1:size(mrWav,1), mrWav, ...
%         1:1/nInterp:size(mrWav,1), 'spline');
%     mrWav1 = mrWav;
    mrWav = zeros(size(mrWav1,1)*nInterp, size(mrWav1,2));
    for iChan=1:size(mrWav1,2)
        mrWav(:,iChan) = interp(mrWav1(:,iChan), nInterp);
    end
%     clear mrWav1;
end

if nargout == 0
    nPlot = 1000;
    
    figure; hold on;
    vrTime = 1:nPlot;
    vrTime1 = 1:1/nInterp:nPlot;
    plot(vrTime, mrWav1(vrTime,1), 'r-');
    plot(vrTime1, mrWav(1:numel(vrTime1),1), 'b-');
    title('r:raw, b:interp');
end
