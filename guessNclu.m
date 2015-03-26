function [cl, icl, nclu] = guessNclu(rho, delta, varargin)
P = funcInStr(varargin{:});
if ~isfield(P, 'SIGMA_FACTOR'), P.SIGMA_FACTOR = 4; end
if ~isfield(P, 'EXCL_DELTA'), P.EXCL_DELTA = .01; end
if ~isfield(P, 'EXCL_RHO'), P.EXCL_RHO = .01; end
if ~isfield(P, 'nclu'), P.nclu = []; end

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

if ~isempty(P.nclu)
    [~, viY1] = sort(y1, 'descend');
    viOut = viY1(1:P.nclu);
else
    viOut = find(y1 > std(y1)*P.SIGMA_FACTOR); %6 sigma
end
if isempty(viOut), [~, viOut] = max(y1); end
[~, viiOut] = sort(y1(viOut), 'descend');
viOut = viOut(viiOut);
viClu = viPlot(viOut);


cl = -1 * ones(ND,1);
nclu = numel(viClu);
cl(viClu) = 1:nclu;
icl(1:nclu) = viClu;

% figure; plot(x, y1/std(y1), '.'); xlabel('log rho'); ylabel('z-delta'); 
% hold on; plot(x(viOut), y1(viOut)/std(y1), 'r.'); 

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
