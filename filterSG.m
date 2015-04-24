function [trSG0, trSG1, trSG2] = filterSG(tr, diffOrder, polyOrder)
% Savitzky-Golay filter

if nargin < 3
    polyOrder = 4; %polynomial order
end
if nargin < 2
    diffOrder = 5;                % Window length
end

[~,mrFilt] = sgolay(polyOrder,diffOrder);   % Calculate S-G coefficients
vrFilt0 = mrFilt(:,1);
if nargout >= 2 || nargout == 0
    vrFilt1 = mrFilt(:,2);
else
    vrFilt1 = [];
end
if nargout >= 3 || nargout == 0
    vrFilt2 = mrFilt(:,3);
else
    vrFilt2 = [];
end

if nargin<1
    dx=.1;
    x=0:dx:2*pi;
    tr = sin(x)';
end

HalfWin  = (diffOrder-1)/2;

%if 3dmat
trSG0 = trShift(trFilter(tr, vrFilt0), HalfWin);
if ~isempty(vrFilt1)
    trSG1 = trShift(trFilter(tr, vrFilt1), HalfWin);
end
if ~isempty(vrFilt2)
    trSG2 = trShift(trFilter(tr, vrFilt2), HalfWin);
end

if nargout==0
    figure; hold on;
    trPlot(tr-1);
    trPlot(trSG0-1, 'linestyle', ':');
    trPlot(trSG1);
    trPlot(trSG2);
end