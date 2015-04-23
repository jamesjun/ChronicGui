% slope analysis stability

%% slope analysis
% iClu = 1;
nSlope = 5;
nInterp = 1;
nClus = max(S.Sclu.cl);
viRange = 1:size(S.trSpkWav,1);
viRange1 = 33 + (-5:8);
csMeas = {'CV(Vpp)', 'CV(Vmax)', 'CV(Vmin)', ...
    'CV(Spp)', 'CV(Smax)', 'CV(Smin)', 'CV(Spp/Vpp)'};
nMeas = numel(csMeas);

cv = @(x)mean(x)/std(x);

mrMeas = zeros(nMeas, nClus);
for iClu=1:nClus

mr = reshape(S.trSpkWav(viRange,8,S.Sclu.cl == iClu), numel(viRange), []);
if nInterp>1
    mr = interp1(1:numel(viRange), mr, 1:1/nInterp:numel(viRange), 'spline');
end

viRange = 1:size(S.trSpkWav,1);
mr1 = reshape(S.trSpkWav(viRange1,8,S.Sclu.cl == iClu), numel(viRange1), []);
mr1 = differentiate(mr1, nSlope);
if nInterp>1
    mr1 = interp1(1:numel(viRange1), mr1, 1:1/nInterp:numel(viRange1), 'spline');
end
mrMeas(:,iClu) = [cv(max(mr)-min(mr)), cv(max(mr)), cv(-min(mr)), ...
    cv(max(mr1)-min(mr1)), cv(max(mr1)), cv(-min(mr1)), ...
    cv((max(mr1)-min(mr1))./(max(mr)-min(mr)))];
% mr1 = bsxfun(@minus, mr1, mr1(1,:));

fprintf('iClu: %d, CV(Vpp)=%0.3f, CV(Vmax)=%0.3f, CV(-Vmin)=%0.3f\n', ...
    iClu, mrMeas(1:3,iClu));
fprintf('\tCV(Spp)=%0.3f, CV(Smax)=%0.3f, CV(-Smin)=%0.3f\n', ...
    mrMeas(4:6,iClu));
end
figure; bar(mean(mrMeas'));
set(gca, 'XTickLabel', csMeas);
ylabel('mean/SD');

% 
% iClu: 1, CV(Vpp)=5.398, CV(Vmax)=4.259, CV(Vmin)=-4.888
% 	CV(Spp)=3.974, CV(Smax)=3.990, CV(Smin)=-3.470
% iClu: 2, CV(Vpp)=5.485, CV(Vmax)=3.817, CV(Vmin)=-3.569
% 	CV(Spp)=3.911, CV(Smax)=3.199, CV(Smin)=-3.118
% iClu: 3, CV(Vpp)=4.677, CV(Vmax)=3.729, CV(Vmin)=-3.069
% 	CV(Spp)=3.744, CV(Smax)=3.363, CV(Smin)=-2.904
% iClu: 4, CV(Vpp)=4.877, CV(Vmax)=3.478, CV(Vmin)=-3.314
% 	CV(Spp)=3.746, CV(Smax)=2.961, CV(Smin)=-2.980
% iClu: 5, CV(Vpp)=5.451, CV(Vmax)=4.851, CV(Vmin)=-5.158
% 	CV(Spp)=3.974, CV(Smax)=4.193, CV(Smin)=-3.470
% iClu: 6, CV(Vpp)=4.436, CV(Vmax)=3.804, CV(Vmin)=-2.908
% 	CV(Spp)=3.575, CV(Smax)=3.329, CV(Smin)=-2.678
% iClu: 7, CV(Vpp)=4.538, CV(Vmax)=3.650, CV(Vmin)=-3.046
% 	CV(Spp)=2.633, CV(Smax)=2.519, CV(Smin)=-2.151
% iClu: 8, CV(Vpp)=6.339, CV(Vmax)=4.816, CV(Vmin)=-4.817
% 	CV(Spp)=4.303, CV(Smax)=4.415, CV(Smin)=-3.521
% iClu: 9, CV(Vpp)=6.016, CV(Vmax)=2.268, CV(Vmin)=-9.336
% 	CV(Spp)=3.759, CV(Smax)=3.819, CV(Smin)=-2.967
% iClu: 10, CV(Vpp)=4.380, CV(Vmax)=3.753, CV(Vmin)=-2.819
% 	CV(Spp)=2.646, CV(Smax)=2.553, CV(Smin)=-2.239