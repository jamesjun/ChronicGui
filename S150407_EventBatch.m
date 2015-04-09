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
fMeanSubt = 6;
thresh = [];
fDiffPair = 0;
fMeasureEvent = 1;
vcFet = 'vpp';
vcPeak = 'vpp';

fCluster = 0;
funcFet = [];
SIGMA_FACTOR = 6;

fDebug = 0;

%%
% %60% spent on load time 
if fDebug
    nAnimals = 1; tDuration = 200; fSave = 0; fParfor = 0; 
    viDay = 20; viShank = 1; fPlot = 1;%debug
    fDiffPair = 0; fMeasureEvent = 1; fCluster = 1; fMeanSubt = 2; thresh = [];
end
tic
% for fDiffPair = 0:1
for iAnimal = 1:nAnimals
    tic
    try
        vcAnimal = csAnimals{iAnimal};
        obj = Animal(vcAnimal, 'readDuration', [0 tDuration], ...
            'fParfor', fParfor, 'fOverwrite', 0);
        obj = obj.getFet('fCluster', fCluster, 'fPlot', fPlot, ...
            'fDiffPair', fDiffPair, 'readDuration', [0 tDuration], ...
            'fParfor', fParfor, ...
            'vcFet', vcFet, 'funcFet', funcFet, ...
            'viDay', viDay, 'viShank', viShank, 'maxAmp', 500, ...
            'fKeepNoiseClu', 0, 'freqLim', freqLim, ...
            'SIGMA_FACTOR', SIGMA_FACTOR, ...
            'fMeasureEvent', fMeasureEvent, 'vcPeak', vcPeak, ...
            'fMeanSubt', fMeanSubt, 'thresh', thresh, 'vcDist', 'euclidean');
%         obj.plotBarClu(); 
        obj.plotEvents();
        if fSave
            eval(sprintf('%s = obj;', vcAnimal));
            clear obj;
            eval(sprintf('save D150407evt_%s_%d %s -v7.3;', ...
                vcAnimal, tDuration, vcAnimal));
            clear(vcAnimal);
        end
    catch
        fprintf('%s, %s\n', lasterr, vcAnimal);
    end
    toc
end
% end
toc