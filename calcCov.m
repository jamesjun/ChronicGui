function mrCov = calcCov(trWav)
vcMode = 'cov'; %cov corr prod
% nWav = size(trWav, 1);
nChans = size(trWav, 2);
nSpk = size(trWav, 3);
if nChans < 2, mrCov = []; return; end

nPairs = 2*nChans-3;
viChan1 = repmat(2:nChans, [2 1]); 
viChan1 = viChan1(2:end);
viChan2 = repmat(1:(nChans-1), [2 1]);
viChan2 = viChan2(1:end-1);

mrCov = zeros([nPairs, nSpk], 'single');
switch lower(vcMode)
    case 'prod'
        for iSpk = 1:nSpk
            mrCov(:, iSpk) = sum(trWav(:,viChan1,iSpk) .* trWav(:,viChan2,iSpk)); 
        end
    case 'cov'
        for iSpk=1:nSpk
            mrA = trWav(:,viChan1,iSpk);
            mrB = trWav(:,viChan2,iSpk);    
            mrCov(:, iSpk) = ...
                mean(bsxfun(@minus, mrA, mean(mrA)) .* bsxfun(@minus, mrB, mean(mrB)));    

        %     mrCov(:, iSpk) = sum(trWav(:,viChan1,iSpk) .* trWav(:,viChan2,iSpk));    
        end
    case 'corr'
        for iSpk=1:nSpk
            mrA = trWav(:,viChan1,iSpk);
            mrB = trWav(:,viChan2,iSpk);    
            mrCov(:, iSpk) = ...
                mean(bsxfun(@minus, mrA, mean(mrA)) .* bsxfun(@minus, mrB, mean(mrB))) ...
                ./ (std(mrA) .* std(mrB));    

        %     mrCov(:, iSpk) = sum(trWav(:,viChan1,iSpk) .* trWav(:,viChan2,iSpk));    
        end
end

    