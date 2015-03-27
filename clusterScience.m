function S = clusterScience(mrPeak, varargin)
%mrPeak: matrix of features
P = funcDefStr(funcInStr(varargin{:}), ...
    'vcDist', 'euclidean', ...
    'deltamin', [], ...
    'rhomin', [], ...
    'fPlot', 0, ...
    'fPlotMds', 0, ...
    'vcTitle', '', ...
    'fAskUser', 1, ...
    'nClu', [], ...
    'fReassign', 0, ...
    'GaussianKernel', 1, ...
    'fHalo', 0, ...
    'percent', 2, ...
    'subsample', 10); %1 in 10 subsampled

P.fPlot = nargout == 0;
dist = single(pdist(mrPeak', P.vcDist))';
nPoints = size(mrPeak, 2);
% NL = nPoints-1;
ND = nPoints;
N=numel(dist);

viDist = random('unid', N, [round(N/P.subsample),1]); %random index
sda=sort(dist(viDist), 'ascend');
dc=sda(round(N / P.subsample * P.percent/100));
viDist = [];

% sda=sort(dist(1:P.subsample:end), 'ascend');
% dc=sda(round(N / P.subsample * P.percent/100))

maxd = max(dist);
sda = []; %free memory
fprintf('average percentage of neighbours (hard coded): %5.6f\n', P.percent);
fprintf('Computing Rho with gaussian kernel of radius: %12.6f\n', dc);

dist = squareform(dist); %to be replaced
% dist1 = zeros(ND, 'single');
% dist1(tril(true(ND),-1)) = dist;
% dist1(triu(true(ND),1)) = dist;
% dist = dist1;

if P.GaussianKernel       
    rho = (sum(exp(-dist.^2 / dc^2))-1)*2;
else
    rho = zeros(ND,1, 'single');

    for i=1:ND-1
        j = (i+1):ND;
        j = j(dist(j,i) < dc);
        rho(i) = rho(i) + numel(j);
        rho(j) = rho(j) + 1;
    end
end


% determine delta
[~,ordrho]=sort(rho,'descend');

% tic
if P.fHalo, dist0 = dist; end
dist = dist(ordrho, ordrho); %expensive memory, so reuse
dist(tril(true(ND), 0)) = inf;
[delta, vimin] = min(dist);
delta(ordrho) = delta;
nneigh(ordrho) = ordrho(vimin);
delta(ordrho(1)) = maxd;
nneigh(ordrho(1))=0;
delta=delta';
dist = []; %free memory
if P.fHalo, dist = dist0; end

% std(delta0-delta)
% std(nneigh0-nneigh)
% figure; plot(delta0, delta, '.');
% figure; plot(nneigh0, nneigh, '.');

% 
% tic
% dist1 = dist(ordrho, ordrho);
% dist1(tril(true(ND),0)) = inf;
% [delta1, nneigh1] = min(dist1);
% delta1(ordrho) = delta1;
% nneigh1(ordrho) = nneigh1;
% % delta1(ordrho(1))=-1.;
% nneigh1(ordrho(1))=0;
% delta1(ordrho(1))=max(delta1(:));
% toc

% disp('Generated file:DECISION GRAPH')
% disp('column 1:Density')
% disp('column 2:Delta')

% fid = fopen('DECISION_GRAPH', 'w');
% for i=1:ND
%    fprintf(fid, '%6.2f %6.2f\n', rho(i),delta(i));
% end

% disp('Select a rectangle enclosing cluster centers')
% scrsz = get(0,'ScreenSize');
% if P.fPlot
%     figure('Position',[6 72 scrsz(3)/4. scrsz(4)/1.3]);
% end
% ind = 1:ND;
%gamma = rho .* delta;
% for i=1:ND
%   ind(i)=i;
%   gamma(i)=rho(i)*delta(i);
% end

% if nargout > 0, return; end

% subplot(2,1,1)

if P.fPlot || P.fAskUser
    fig = figure; %('Position',[6 72 scrsz(3)/4. scrsz(4)/1.3]);
    %     uiwait(msgbox('reposition and hit ok'));
    tt=plot(rho(:),delta(:),'o','MarkerSize',5,'MarkerFaceColor','k','MarkerEdgeColor','k');
    title(P.vcTitle)
    xlabel ('\rho')
    ylabel ('\delta')
    set(gca, {'XScale', 'YScale'}, {'log', 'log'});
%     axis([1e-3 1e4 1e1 1e3])    
    if P.fAskUser
        uiwait(msgbox('Click outlier location'));
        figure(fig);
        [P.rhomin, P.deltamin] = ginput(1);
        fprintf('rhomin: %f, deltamin: %f\n', P.rhomin, P.deltamin);    
    end
end
% else
%     if ~isempty(P.rhomin) && ~isempty(P.deltamin) %auto determine
%         rhomin = P.rhomin;
%         deltamin = P.deltamin; 
%     else
% %         nClu = guessNclu(rho, delta);
%         [rhomin, deltamin, nclu] = guessNclu(rho, delta, P.nclu);      %TODO: return index   
% %         viRho = ordrho(end-4:end); %10 elements
% %         deltamin = mean(delta(viRho));
% %         rhomin = rho(viRho(1));
% %         [rhomin, imin] = min(rho(:));
% %         deltamin = delta(imin);
%     end

% uiwait(msgbox('rescale'));
if isempty(P.rhomin) || isempty(P.deltamin)
    [cl, icl, NCLUST] = guessNclu(rho, delta, P);
else
    NCLUST=0;
    cl = -1 * ones(ND,1);
    for i=1:ND
      if ( (rho(i)>=P.rhomin) && (delta(i)>=P.deltamin))
         NCLUST=NCLUST+1;
         cl(i)=NCLUST;
         icl(NCLUST)=i;
      end
    end 
end

fprintf('NUMBER OF CLUSTERS: %i \n', NCLUST);
disp('Performing assignation')

if NCLUST == 0
    S = [];
    return; 
end

%assignation
for i=1:ND
  if (cl(ordrho(i))==-1)
    cl(ordrho(i))=cl(nneigh(ordrho(i)));
  end
end



%halo
if P.fHalo
    halo = cl;
    if (NCLUST>1)
        bord_rho = zeros(NCLUST,1);
        for i=1:ND-1
            j=i+1:ND;
            j = j((cl(i)~=cl(j)) & (dist(j,i)<=dc));
            if ~isempty(j)
                rho_aver=(rho(i)+rho(j))/2.;
                bord_rho(cl(i)) = max(bord_rho(cl(i)), max(rho_aver));
                bord_rho(cl(j)) = max(bord_rho(cl(j)), rho_aver);
            end

        end %i
        halo(rho < bord_rho(cl)) = nan; %backgorund cluster, instead of 0 JJJ
    end
else
    halo = [];
end

for iClu=1:NCLUST
  nc = sum(cl==iClu);
  if ~isempty(halo)
      nh = sum(halo==iClu);
  else
      nh = nan;
  end
  fprintf('CLUSTER: %i CENTER: %i ELEMENTS: %i CORE: %i HALO: %i \n', ...
      iClu,icl(iClu),nc,nh,nc-nh);
end

if P.fPlotMds
    subplot(2,1,2)
    disp('Performing 2D nonclassical multidimensional scaling')
    Y1 = mdscale(dist, 2, 'criterion','metricstress');
    plot(Y1(:,1),Y1(:,2),'o','MarkerSize',2,'MarkerFaceColor','k','MarkerEdgeColor','k');
    title ('2D Nonclassical multidimensional scaling','FontSize',15.0)
    xlabel ('X')
    ylabel ('Y')

    A = zeros(ND, 2);
    for i=1:NCLUST
      nn=0;
      for j=1:ND
        if (halo(j)==i)
          nn=nn+1;
          A(nn,1)=Y1(j,1);
          A(nn,2)=Y1(j,2);
        end
      end
      hold on
      plot(A(1:nn,1),A(1:nn,2),'o','MarkerSize',2,'MarkerFaceColor',mrColor(i,:),'MarkerEdgeColor',mrColor(i,:));
    end
end

%for i=1:ND
%   if (halo(i)>0)
%      ic=int8((halo(i)*64.)/(NCLUST*1.));
%      hold on
%      plot(Y1(i,1),Y1(i,2),'o','MarkerSize',2,'MarkerFaceColor',cmap(ic,:),'MarkerEdgeColor',cmap(ic,:));
%   end
%end
% faa = fopen('CLUSTER_ASSIGNATION', 'w');
% disp('Generated file:CLUSTER_ASSIGNATION')
% disp('column 1:element id')
% disp('column 2:cluster assignation without halo control')
% disp('column 3:cluster assignation with halo control')

% mrClu = [(1:ND)', cl(:), halo(:)];
% for i=1:ND
%    fprintf(faa, '%i %i %i\n',i,cl(i),halo(i));
% end

% reassignment by size of elements per clusters
if P.fReassign
    viClu = 1:max(cl);
    [~, viSort] = sort(hist(halo, viClu), 'descend'); %sort by population, descending order
    viClu(viSort) = 1:max(cl);
    cl = viClu(cl);
    halo(isnan(halo)) = viSort(1); %most populus
    halo = viClu(halo);
    icl(viClu) = icl;
else
    halo(isnan(halo)) = 1; %set to background cluster
end

if P.fPlot
    figure(fig); hold on;
    mrColor = [.5 .5 .5; jet(NCLUST-1)];
    for iClu=1:NCLUST   
       plot(rho(icl(iClu)),delta(icl(iClu)),'o','MarkerSize',8,'MarkerFaceColor',...
           mrColor(iClu,:),'MarkerEdgeColor',mrColor(iClu,:));
    end
end

S = struct('rho', rho, 'delta', delta, 'cl', cl, 'halo', halo, 'icl', icl);