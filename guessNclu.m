function [cl, icl, nclu] = guessNclu(rho, delta, varargin)
P = funcInStr(varargin{:});
if ~isfield(P, 'SIGMA_FACTOR'), P.SIGMA_FACTOR = 4; end
if ~isfield(P, 'EXCL_DELTA'), P.EXCL_DELTA = .01; end
if ~isfield(P, 'EXCL_RHO'), P.EXCL_RHO = .01; end
if ~isfield(P, 'nclu'), P.nclu = []; end
if ~isfield(P, 'MAX_RHO_RATIO'), P.MAX_RHO_RATIO = .1; end
if ~isfield(P, 'fPlot'), P.fPlot = 1; end

P.fPlot = 0; %override

ND = numel(rho);
ND_DELTA = ceil(ND*P.EXCL_DELTA); %1/10 population outlier
ND_RHO = ceil(ND*P.EXCL_RHO); %1/10 population outlier
delta = delta(:);
rho = rho(:);
[~, viDelta] = sort(delta, 'ascend');
[~, viRho] = sort(rho, 'ascend');
viKill = union(viDelta(1:ND_DELTA), viRho(1:ND_RHO));
% viKill = viDelta(1:ND1);
viPlot = (1:ND);
viPlot(viKill) = [];

% n = 10;
% thresh = 2;
% if nargin < 3
%     nclu = [];
% end

x = log(rho(viPlot));
y = delta(viPlot);
mb = [x, ones(size(x))] \ y;
y1 = y - mb(1)*x - mb(2); 
std_y1 = std(y1);

if ~isempty(P.nclu)
    [~, viY1] = sort(y1, 'descend');
    viOut = viY1(1:P.nclu);
else
    viOut = find(y1 > std_y1*P.SIGMA_FACTOR); %6 sigma
end
if isempty(viOut), [~, viOut] = max(y1); end
[~, viiOut] = sort(y1(viOut), 'descend');
viOut = viOut(viiOut);
viClu = viPlot(viOut);
maxRho = rho(viClu(1)) * P.MAX_RHO_RATIO;
vl = rho(viClu) < maxRho;
vl(1) = 1; %preserve the noise cluster
viClu = viClu(vl);

cl = -1 * ones(ND,1);
nclu = numel(viClu);
cl(viClu) = 1:nclu;
icl(1:nclu) = viClu;

if P.fPlot
    xp = log(rho);
    yp = (delta - mb(1)*xp - mb(2))/std_y1; 
    figure; plot(xp, yp, '.'); xlabel('log rho'); ylabel('z-delta'); 
    hold on; plot(xp(viClu), yp(viClu), 'r.'); 
    hold on; plot(get(gca, 'XLim'), P.SIGMA_FACTOR * [1,1], 'r-');
end

% figure; plot(
% % r = 1:n;
% % viG = r - n + numel(vrG);
% % vrY = log(vrG(r));
% 
% % plot(r, vrY, '.');
% % vrG = vrG(end-100:end);
% % vrYd = ;
% vrYd = -diff(vrG);
% vrYd = vrYd / median(vrYd);
% % figure; bar(vrYd);
% if isempty(nclu)
%     nclu = find(vrYd>thresh, 1, 'last') + 1; %threshold
%     if isempty(nclu), nclu = 1; end
% end
% 
% viCl = viG(1:nclu);
% cl(viCl) = 1:nclu;
% icl(1:nclu) = viCl;
