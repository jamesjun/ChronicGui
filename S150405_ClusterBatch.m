csAnimals = {'ANM282996', 'ANM286577', 'ANM286578', 'ANM292757', ...
    'ANM279097', 'ANM279094', 'ANM287075', 'ANM287074'};
fSave = 1;
tDuration = 900;
fParfor = 1;
nAnimals = numel(csAnimals);
viDay = [];
viShank = [];
fPlot = 0;
freqLim = [500 6000];
SIGMA_FACTOR = 6;
fCluster = 0;

fDebug = 1;

%%
% %60% spent on load time 
if fDebug
    nAnimals = 1; tDuration = 90; fSave = 0; fParfor = 0; 
    viDay = 19:21; viShank = 1; fPlot = 0;%debug
    fDiffPair = 0; fMeasureEvent = 1; fCluster = 0; fMeanSubt = 2; thresh = [];
end

% for fDiffPair = 0:1
    for iAnimal = 1:nAnimals
        try
            vcAnimal = csAnimals{iAnimal};
            obj = Animal(vcAnimal, 'readDuration', [0 tDuration], ...
                'fParfor', fParfor, 'fOverwrite', 0);
            obj = obj.getFet('fCluster', fCluster, 'fPlot', fPlot, ...
                'fDiffPair', fDiffPair, 'readDuration', [0 tDuration], ...
                'fParfor', fParfor, ...
                'vcFet', '@(x)max(x)-min(x)', 'funcFet', @(x)sqrt(x), ...
                'viDay', viDay, 'viShank', viShank, 'maxAmp', 1000, ...
                'fKeepNoiseClu', 0, 'freqLim', freqLim, ...
                'SIGMA_FACTOR', SIGMA_FACTOR, ...
                'fMeasureEvent', fMeasureEvent, ...
                'fMeanSubt', fMeanSubt, 'thresh', thresh);
%             obj.plotBarClu(); 
            obj.plotEvents('viShank', viShank);
            if fSave
                eval(sprintf('%s = obj;', vcAnimal));
                clear obj;
                eval(sprintf('save %s_%d_diff%d %s -v7.3;', vcAnimal, tDuration, fDiffPair, vcAnimal));
                clear(vcAnimal);
            end
        catch
            fprintf('%s, %s\n', lasterr, vcAnimal);
        end
    end
% end
