function plotScienceClu(Sclu)
rho = Sclu.rho;
delta = Sclu.delta;
cl = Sclu.cl;
icl = Sclu.icl;

NCLUST = max(cl);

%     uiwait(msgbox('reposition and hit ok'));
plot(rho(:),delta(:),'o','MarkerSize',5,'MarkerFaceColor','k','MarkerEdgeColor','k');
title('Decision graph')
xlabel ('\rho')
ylabel ('\delta')
set(gca, {'XScale', 'YScale'}, {'log', 'log'});
% axis([1e-3 1e4 1e1 1e3])

hold on;
mrColor = [.5 .5 .5; jet(NCLUST-1)];
for iClu=1:NCLUST   
   plot(rho(icl(iClu)),delta(icl(iClu)),'o','MarkerSize',8,'MarkerFaceColor',...
       mrColor(iClu,:),'MarkerEdgeColor',mrColor(iClu,:));
end
