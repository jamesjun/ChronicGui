function S = clusterScience(mrPeak, varargin)
%mrPeak: matrix of features

vrDist = pdist(mrPeak')';
nPoints = size(mrPeak, 2);
vrFet1 = zeros(size(vrDist));
vrFet2 = zeros(size(vrDist));
i1 = 1;
for i = 1:(nPoints-1)
    i2 = i1 + nPoints - i - 1;
    vrFet1(i1:i2) = i;
    vrFet2(i1:i2) = (i+1):nPoints;
    i1 = i2+1;
end
mrFet = [vrFet1, vrFet2, vrDist];

P = struct(varargin{:});
if ~isfield(P, 'fPlot'), P.fPlot = (nargout == 0); end 

ND=max(mrFet(:,2));
NL=max(mrFet(:,1));
if (NL>ND)
  ND=NL;
end
N=size(mrFet,1);


dist = zeros(ND, ND);
dist(sub2ind([ND, ND], mrFet(:,1), mrFet(:,2))) = mrFet(:,3);
dist(sub2ind([ND, ND], mrFet(:,2), mrFet(:,1))) = mrFet(:,3);

% tic
% for i=1:ND
%   for j=1:ND
%     dist(i,j)=0;
%   end
% end
% for i=1:N
%   ii=mrFet(i,1);
%   jj=mrFet(i,2);
%   dist(ii,jj)=mrFet(i,3);
%   dist(jj,ii)=mrFet(i,3);
% end
% toc

percent=2.0;
fprintf('average percentage of neighbours (hard coded): %5.6f\n', percent);

position=round(N*percent/100);
sda=sort(mrFet(:,3));
dc=sda(position);

fprintf('Computing Rho with gaussian kernel of radius: %12.6f\n', dc);

% Gaussian kernel
rho = zeros(ND,1);
expdist2 = exp(-dist.*dist / dc^2);
for i=1:ND-1
  for j=i+1:ND
     rho(i)=rho(i)+expdist2(i,j);
     rho(j)=rho(j)+expdist2(i,j);
  end
end
%
% "Cut off" kernel
%
%for i=1:ND-1
%  for j=i+1:ND
%    if (dist(i,j)<dc)
%       rho(i)=rho(i)+1.;
%       rho(j)=rho(j)+1.;
%    end
%  end
%end

maxd=max(max(dist));

[~,ordrho]=sort(rho,'descend');
delta(ordrho(1))=-1.;
nneigh(ordrho(1))=0;

for ii=2:ND
   delta(ordrho(ii))=maxd;
   for jj=1:ii-1
     if(dist(ordrho(ii),ordrho(jj))<delta(ordrho(ii)))
        delta(ordrho(ii))=dist(ordrho(ii),ordrho(jj));
        nneigh(ordrho(ii))=ordrho(jj);
     end
   end
end
delta(ordrho(1))=max(delta(:));
disp('Generated file:DECISION GRAPH')
disp('column 1:Density')
disp('column 2:Delta')

% fid = fopen('DECISION_GRAPH', 'w');
% for i=1:ND
%    fprintf(fid, '%6.2f %6.2f\n', rho(i),delta(i));
% end

disp('Select a rectangle enclosing cluster centers')
scrsz = get(0,'ScreenSize');
if P.fPlot
    figure('Position',[6 72 scrsz(3)/4. scrsz(4)/1.3]);
end
% ind = 1:ND;
%gamma = rho .* delta;
% for i=1:ND
%   ind(i)=i;
%   gamma(i)=rho(i)*delta(i);
% end

% if nargout > 0, return; end

% subplot(2,1,1)
tt=plot(rho(:),delta(:),'o','MarkerSize',5,'MarkerFaceColor','k','MarkerEdgeColor','k');
title ('Decision Graph','FontSize',15.0)
xlabel ('\rho')
ylabel ('\delta')
set(gca, {'XScale', 'YScale'}, {'log', 'log'});

% uiwait(msgbox('rescale'));
[rhomin deltamin] = ginput(1);
NCLUST=0;
cl = -1 * ones(ND,1);
% for i=1:ND
%   cl(i)=-1;
% end
for i=1:ND
  if ( (rho(i)>rhomin) && (delta(i)>deltamin))
     NCLUST=NCLUST+1;
     cl(i)=NCLUST;
     icl(NCLUST)=i;
  end
end

fprintf('NUMBER OF CLUSTERS: %i \n', NCLUST);
disp('Performing assignation')

%assignation
for i=1:ND
  if (cl(ordrho(i))==-1)
    cl(ordrho(i))=cl(nneigh(ordrho(i)));
  end
end
%halo
halo = cl;
% for i=1:ND
%   halo(i)=cl(i);
% end
if (NCLUST>1)
  bord_rho = zeros(NCLUST,1);
%   for i=1:NCLUST
%     bord_rho(i)=0.;
%   end
  for i=1:ND-1
    for j=i+1:ND
      if ((cl(i)~=cl(j))&& (dist(i,j)<=dc))
        rho_aver=(rho(i)+rho(j))/2.;
        if (rho_aver>bord_rho(cl(i))) 
          bord_rho(cl(i))=rho_aver;
        end
        if (rho_aver>bord_rho(cl(j))) 
          bord_rho(cl(j))=rho_aver;
        end
      end
    end
  end
  for i=1:ND
    if (rho(i)<bord_rho(cl(i)))
      halo(i)=0;
    end
  end
end
for i=1:NCLUST
  nc=0;
  nh=0;
  for j=1:ND
    if (cl(j)==i) 
      nc=nc+1;
    end
    if (halo(j)==i) 
      nh=nh+1;
    end
  end
  fprintf('CLUSTER: %i CENTER: %i ELEMENTS: %i CORE: %i HALO: %i \n', i,icl(i),nc,nh,nc-nh);
end

% cmap=colormap;
% ic = int8((1:NCLUST)/NCLUST * 64); %color index
mrColor = jet(NCLUST);
for i=1:NCLUST   
%    subplot(2,1,1)
   hold on
   plot(rho(icl(i)),delta(icl(i)),'o','MarkerSize',8,'MarkerFaceColor',mrColor(i,:),'MarkerEdgeColor',mrColor(i,:));
end
    
if P.fPlot
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

S = struct('rho', rho, 'delta', delta, 'cl', cl, 'halo', halo);