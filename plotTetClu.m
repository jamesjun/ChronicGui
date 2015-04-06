function plotTetClu(mrPeak, varargin)
nChans = size(mrPeak, 1);

P = funcInStr(varargin{:});
if ~isfield(P, 'viClu'), P.viClu = []; end
if ~isfield(P, 'maxAmp'), P.maxAmp = 800; end
if ~isfield(P, 'shankOffY'), P.shankOffY = 0; end
if ~isfield(P, 'vcTitle'), P.vcTitle = ''; end
if ~isfield(P, 'iCluNoise'), P.iCluNoise = []; end
if ~isfield(P, 'fLog'), P.fLog = 0; end

viTetChOff = 0:4:nChans-4;
if numel(viTetChOff) < ceil(nChans/4)
    viTetChOff(end+1) = nChans-4;
end
nTets = numel(viTetChOff);
mrTet = [1 1 1 2 2 3; 2 3 4 3 4 4];
nPairs = size(mrTet,2);
set(gca, {'Color', 'XTick', 'YTick'}, {'k',[],[]});
axis equal;
hold on;
if ~isempty(P.viClu)
    mrColor = [.5, .5, .5; jet(max(P.viClu)-1)];
end
if P.fLog
    [mrPeak, minval] = logpos(mrPeak);
    ampLim = log([minval, P.maxAmp]);
else
    ampLim = [0, P.maxAmp];
end
for iTet = nTets:-1:1
   for iPair = 1:nPairs
        ch1 = mrTet(1, iPair) + viTetChOff(iTet);
        ch2 = mrTet(2, iPair) + viTetChOff(iTet);
        vrX1 = linmap(mrPeak(ch2,:), ampLim, [0 1]) + (iPair-1);
        vrY1 = linmap(mrPeak(ch1,:), ampLim, [0 1]) + (iTet-1) + P.shankOffY;  
        if isempty(P.viClu)
            plot(vrX1, vrY1, 'w.', 'MarkerSize', 1);
        else
            scatter(vrX1, vrY1, 3, mrColor(P.viClu,:), 'filled');
        end
        plot([0 0 1 1 0]+iPair-1, [0 1 1 0 0]+iTet-1 + P.shankOffY, 'w');
   end
end        
axis([0, nPairs, 0, nTets + P.shankOffY]);
plot([0 0 1 1 0]*nPairs, [0 1 1 0 0]*nTets + P.shankOffY, 'w', 'LineWidth', 2);
title(P.vcTitle);
set(gca, {'XScale', 'YScale'}, {'linear', 'linear'});

% try tightfig; catch disp(lasterr); end
% colormap jet;
end %func