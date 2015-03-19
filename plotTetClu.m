function plotTetClu(mrPeak, varargin)
nChans = size(mrPeak, 1);

if isstruct(varargin{1}), P = varargin{1};
else P = struct(varargin{:}); end

if ~isfield(P, 'viClu'), P.viClu = []; end
if ~isfield(P, 'maxAmp'), P.maxAmp = 800; end
if ~isfield(P, 'shankOffY'), P.shankOffY = 0; end

if nChans == 11, viTetChOff = [0 4 7];
else viTetChOff = 0:4:nChans-4;
end
nTets = numel(viTetChOff);
mrTet = [1 1 1 2 2 3; 2 3 4 3 4 4];
nPairs = size(mrTet,2);
set(gca, {'Color', 'XTick', 'YTick'}, {'k',[],[]});
axis equal;
hold on;
for iTet = nTets:-1:1
   for iPair = 1:nPairs
        ch1 = mrTet(1, iPair) + viTetChOff(iTet);
        ch2 = mrTet(2, iPair) + viTetChOff(iTet);
        vrX1 = linmap(mrPeak(ch2,:), [0 P.maxAmp], [0 1]) + (iPair-1);
        vrY1 = linmap(mrPeak(ch1,:), [0 P.maxAmp], [0 1]) + (iTet-1) + P.shankOffY;  
        if isempty(P.viClu)
            plot(vrX1, vrY1, 'w.', 'MarkerSize', 1);
        else
            vlPlot = P.viClu == 0;
            scatter(vrX1(vlPlot), vrY1(vlPlot), 3, [.5 .5 .5], 'filled');
            
            vlPlot = ~vlPlot; 
            scatter(vrX1(vlPlot), vrY1(vlPlot), 3, P.viClu(vlPlot), 'filled');
        end
        plot([0 0 1 1 0]+iPair-1, [0 1 1 0 0]+iTet-1 + P.shankOffY, 'w');
   end
end        
axis([0, nPairs, 0, nTets + P.shankOffY]);
plot([0 0 1 1 0]*nPairs, [0 1 1 0 0]*nTets + P.shankOffY, 'w', 'LineWidth', 2);
try tightfig; catch disp(lasterr); end

end %func