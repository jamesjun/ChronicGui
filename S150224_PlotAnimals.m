% Plot all animals
addpath(genpath('./nlximport'));
% 
% csAnimals = {'ANM282996', 'ANM286577', 'ANM286578', 'ANM292757', ...
%              'ANM279097', 'ANM279094', 'ANM287075', 'ANM287074'};
csAnimals = {'ANM282996', 'ANM286577', 'ANM287075'};
readDuration = 300;

cAnimals = cell(size(csAnimals));
tic
parfor iAnimal = 1:numel(csAnimals)
    cAnimals{iAnimal} = Animal(csAnimals{iAnimal}, 'readDuration', readDuration);
end
vAnimals = Animal.empty();
for iAnimal = 1:numel(cAnimals)
    vAnimals(iAnimal) = cAnimals{iAnimal};
end
toc
save animals_300s vAnimals;
%31sec with parfor0,1, 32 without parfor1

%% figure; %create subplot 2x3
plotMode = 'ampl'; % 'counts', 'ampl'

figure;
for iAnimal = 1:numel(vAnimals)
% for iAnimal = 6:6
    subplot(2,4,iAnimal); hold on;
    try
%         cAnimals{iAnimal} = cAnimals{iAnimal}.getImpedance(1);
        vAnimals(iAnimal) = vAnimals(iAnimal).getSpikes('plotMode', plotMode);
    catch
        disp(lasterr);
    end
end


%% Plot spike counts
figure;
for iAnimal = 1:numel(cAnimals)
% for iAnimal = 6:6
    subplot(2,3,iAnimal); hold on;
    try
%         cAnimals{iAnimal} = cAnimals{iAnimal}.getImpedance(1);
        cAnimals{iAnimal} = cAnimals{iAnimal}.getSpikes('readDuration', 300, 1);
    catch
        disp(lasterr);
    end
end

%% Plot raster
viDay = [19 20 21];
animal2 = Animal('ANM282996', 'viDay', viDay, 'readDuration', 300);
save animal2 animal2;

%%
clim = [0 300];
nShanks = 4;
nAnimals = numel(vAnimals);

figure;
for iAnimal = 1:numel(vAnimals)
    animal1 = vAnimals(iAnimal);
    iDay = numel(animal1.csXTickLabel);
    for iShank = 1:4
        subplot(nShanks, nAnimals, iShank + (iAnimal-1)*nShanks);
        animal1.plotRaster(iDay, iShank);
        title(sprintf('Day %s, Shank %d', animal1.csXTickLabel{iDay}, iShank));
        caxis(clim);
    end
end


