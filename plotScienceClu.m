function plotScienceClu(Sclu)
rho = Sclu.rho;
delta = Sclu.delta;
cl = Sclu.cl;
icl = Sclu.icl;
% viClu0 = Sclu.viClu0;

xp = Sclu.funX(rho);
yp = Sclu.funY(rho, delta);
plot(xp, yp, 'ko','MarkerSize',3); xlabel('log rho/rhomax'); ylabel('z-delta'); 
% hold on; plot(xp(viClu0), yp(viClu0), 'r.'); 

vrXlim = [Sclu.limX(1), Sclu.limX(1), Sclu.limX(2), Sclu.limX(2), Sclu.limX(1)];
vrYlim = [Sclu.limY(1), Sclu.limY(2), Sclu.limY(2), Sclu.limY(1), Sclu.limY(1)];
hold on;
plot(vrXlim, vrYlim, 'r-');
title(sprintf('exp-xlim:%0.3f..%0.3f, ylim:%0.3f..%0.3f\n', exp(Sclu.limX), Sclu.limY));
%     uiwait(msgbox('reposition and hit ok'));
% plot(rho(:),delta(:),'o','MarkerSize',5,'MarkerFaceColor','k','MarkerEdgeColor','k');
% title('Decision graph')
% xlabel ('\rho')
% ylabel ('\delta')
% set(gca, {'XScale', 'YScale'}, {'log', 'linear'});
% axis([1e-3 1e4 1e1 1e3])
grid on;
hold on;
mrColor = [.5 .5 .5; jet(Sclu.nClu-1)];
for iClu=1:Sclu.nClu   
   plot(xp(icl(iClu)),yp(icl(iClu)),'o','MarkerSize',3, ...
       'MarkerFaceColor',mrColor(iClu,:), ...
       'MarkerEdgeColor', 'none');
end
