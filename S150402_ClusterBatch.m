csAnimals = {'ANM282996', 'ANM286577', 'ANM286578', 'ANM292757', ...
    'ANM279097', 'ANM279094', 'ANM287075', 'ANM287074'};
fSave = 1;
tDuration = 900;
fParfor = 1;
nAnimals = numel(csAnimals);

%%
% %60% spent on load time 
nAnimals = 1; tDuration = 900; fSave = 0; fParfor = 0; %debug

for iAnimal = 1:nAnimals
    try
        vcAnimal = csAnimals{iAnimal};
        if ~exist(vcAnimal, 'var')
            obj = Animal(vcAnimal, 'readDuration', [0 tDuration], ...
                'fParfor', fParfor, 'fOverwrite', 0);
        else
            eval(sprintf('obj = %s;', vcAnimal));
        end
        tic
        obj = obj.getFet('fCluster', 1, 'fPlot', 0, 'fDiffPair', 1, ...
            'readDuration', [0 tDuration], 'fParfor', fParfor);
        toc
        obj.plotBarClu();
        if fSave
            eval(sprintf('%s = obj;', vcAnimal));
            clear obj;
            eval(sprintf('save %s_%d %s -v7.3;', vcAnimal, tDuration, vcAnimal));
            clear(vcAnimal);
        end
    catch
        fprintf('%s, %s\n', lasterr, vcAnimal);
    end
end

%670 s with fDiffPair, fParfor

%% reduced dataset
% obj = Animal('ANM282996');
obj = obj.getFet('fCluster', 1, 'fPlot', 0, 'fDiffPair', 1, ...
    'readDuration', [0 900], 'fParfor', 1, 'viDay', 21, 'viShank', 1, ...
    'fAskUser', 0, 'fOverwrite', 1, 'vcFet', '@(x)min(x)');
% obj.plotClusters();
