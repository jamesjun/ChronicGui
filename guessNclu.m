function [rhomin, deltamin, nclu] = guessNclu(rho, delta)
n = 10;
thresh = 2;

vrG = rho(:) .* delta(:);
[vrG viG] = sort(vrG, 'descend');
r = 1:n;
% viG = r - n + numel(vrG);
vrY = log(vrG(r));

% plot(r, vrY, '.');
% vrG = vrG(end-100:end);
% vrYd = ;
vrYd = -diff(vrY);
vrYd = vrYd / median(vrYd);
% figure; bar(vrYd);
nclu = find(vrYd>thresh, 1, 'last') + 1; %threshold
if isempty(nclu), nclu = 1; end
rhomin = rho(viG(nclu));
deltamin = delta(viG(nclu));
% nclu = nclu+1;
% vrDG = diff(vrG);
% figure; plot(vrG(2:end), vrDG, '.');
% xlabel('log r');
% ylabel('log \gamma(r)');figure; bar(vrYd);

% set(gca, {'XScale', 'YScale'}, {'log', 'log'});
% 

% sem = @(x)std(x)/sqrt(numel(x));
% 
% for i=1:10
%     vr(i) = sem(vrG(1:end-i));
% end
% 
% figure
% bar(diff(vr));
% title(S1.vcDate);