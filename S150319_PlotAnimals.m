% S150311_plotImpedance
warning off
try 
    if ~exist('vAnimals')
        load animals_300s
    end
catch
    % Plot all animals
    addpath(genpath('./nlximport'));

    csAnimals = {'ANM282996', 'ANM286577', 'ANM286578', 'ANM292757', ...
                 'ANM279097', 'ANM279094', 'ANM287075', 'ANM287074'};
    warning off;
    cAnimals = cell(size(csAnimals));
    readDuration = 120;
    parfor iAnimal = 1:numel(csAnimals)
        tic
        cAnimals{iAnimal} = Animal(csAnimals{iAnimal}, 'readDuration', readDuration);
        toc
    end
    vAnimals = Animal.empty();
    for iAnimal = 1:numel(cAnimals)
        vAnimals(iAnimal) = cAnimals{iAnimal};
    end
    save animals_300s vAnimals;
end
% figure; %create subplot 2x3
% plotMode = 'ampl'; % 'counts', 'ampl'
%%
figure;
for iAnimal = 1:numel(vAnimals)
% for iAnimal = 6:6
    subplot(2,4,iAnimal); hold on;
    try
%         vAnimals(iAnimal).getImpedance(1);
        vAnimals(iAnimal).getSpikes('plotMode', 'ampl');
    catch
        disp(lasterr);
    end
end
