function Sclu = guessNclu(Sclu, varargin)
P = funcInStr(varargin{:});
if ~isfield(P, 'SIGMA_FACTOR'), P.SIGMA_FACTOR = 4; end
if ~isfield(P, 'EXCL_DELTA'), P.EXCL_DELTA = .00; end
if ~isfield(P, 'EXCL_RHO'), P.EXCL_RHO = .01; end
if ~isfield(P, 'nClu'), P.nClu = []; end
if ~isfield(P, 'MAX_RHO_RATIO'), P.MAX_RHO_RATIO = .1; end
if ~isfield(P, 'fPlot'), P.fPlot = 1; end
if ~isfield(P, 'fAskUser'), P.fAskUser = 0; end

P.fPlot = 0; %override

rho = Sclu.rho;
delta = Sclu.delta;
nneigh = Sclu.nneigh;
ordrho = Sclu.ordrho;

ND = numel(rho);
delta = delta(:);
rho = rho(:);
[~, viDelta] = sort(delta, 'ascend');
[~, viRho] = sort(rho, 'ascend');
ND_DELTA = ceil(ND*P.EXCL_DELTA); %1/10 population outlier
ND_RHO = ceil(ND*P.EXCL_RHO); %1/10 population outlier
viKill = union(viDelta(1:ND_DELTA), viRho(1:ND_RHO));
% viKill = viDelta(1:ND1);
viPlot = (1:ND)';
viPlot(viKill) = [];

x = logpos(rho(viPlot));
y = delta(viPlot);
mb = [x, ones(size(x))] \ y;
y1 = y - mb(1)*x - mb(2); 
std_y1 = std(y1);
[~, iOut1] = max(y1);
maxLogRho = x(iOut1);
x = x - maxLogRho;
y1 = y1/std_y1;
iSpkClu1 = viPlot(iOut1);
if P.fAskUser
    fig = figure;
    plot(x, y1, '.');    
    grid on;
    axis tight;
    xlabel('log(rho/rhomax)'); ylabel('z-delta-err'); 
    title('Decision graph');
    uiwait(msgbox('drag a rectangle and double-click'));
    vrPos = wait(imrect);
    limX = cumsum(vrPos([1, 3]));
    limY = cumsum(vrPos([2, 4]));  
    close(fig);
elseif ~isempty(P.nClu) %ambiguous case
    error('not supported');
    [~, viY1] = sort(y1, 'descend');
    iMin = viY1(P.nClu);
    limX = [x(iMin), x(iOut1)];
    limY = [y1(iMin), y(iOut1)];
else % directly given
    limX = [min(x), log(P.MAX_RHO_RATIO)];
    limY = [P.SIGMA_FACTOR, max(y1)];
end
viOut = find((limX(1) <= x) & (x <= limX(2)) & ...
    (limY(1) <= y1) & (y1 <= limY(2)));  
[~, viiOut] = sort(y1(viOut), 'descend');
viOut = viOut(viiOut);
if ~ismember(iOut1, viOut)
    viOut = [iOut1; viOut]; %append
end
icl = viPlot(viOut);
nClu = numel(icl);
cl = -1*ones([ND,1], 'single'); %*-1?
cl(icl) = 1:nClu;

%assignation
for i=1:ND
  if (cl(ordrho(i))==-1)
    cl(ordrho(i))=cl(nneigh(ordrho(i)));
  end
end

Sclu.cl = cl;
Sclu.icl = icl;
Sclu.funX = @(x)log(x)-maxLogRho;
Sclu.funY = @(x,y)(y - mb(1)*log(x) - mb(2))/std_y1;
Sclu.limX = limX;
Sclu.limY = limY;
Sclu.nClu = nClu;
% Sclu.viClu0 = viClu0;

if P.fPlot
    figure;
    plotScienceClu(Sclu);
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
