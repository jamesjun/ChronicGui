function plotBar(mrMed, mrHigh, mrLow)
%PLOTBAR Summary of this function goes here
%   http://www.mathworks.com/matlabcentral/answers/102220-how-do-i-place-errorbars-on-my-grouped-bar-graph-using-function-errorbar-in-matlab-7-13-r2011b

if size(mrMed, 1) > 1
    bar(mrMed, 1, 'EdgeColor', 'none');
else
    bar([mrMed; zeros(size(mrMed))], 'EdgeColor', 'none');
end
if nargin == 1 return; end

numbars = size(mrMed, 2);
numgroups = size(mrMed, 1);
groupwidth = min(0.8, numbars/(numbars+1.5));

hold on;
for iBar = 1:numbars
    vrX = (1:numgroups) - groupwidth/2 + (2*iBar-1) * groupwidth / (2*numbars);
    errorbar(vrX, mrMed(:,iBar), ...
        mrMed(:,iBar)-mrLow(:,iBar), ...
        mrHigh(:,iBar)-mrMed(:,iBar), 'k', 'linestyle', 'none');
end
set(gca, 'XTick', 1:numgroups);


