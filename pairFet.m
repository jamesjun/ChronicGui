function mrCov = pairFet(trWav, varargin)
% pairwise feature

% nWav = size(trWav, 1);
P = funcDefStr(funcInStr(varargin{:}), ...
    'nPadding', 0, 'vcPairFet', 'cov');
    
nChans = size(trWav, 2);
nSpk = size(trWav, 3);
if nChans < 2, mrCov = []; return; end

nPairs = 2*nChans-3;
viChan1 = repmat(2:nChans, [2 1]); 
viChan1 = viChan1(2:end);
viChan2 = repmat(1:(nChans-1), [2 1]);
viChan2 = viChan2(1:end-1);

% remove padding
if P.nPadding > 0    
    trWav = trWav((1+P.nPadding):(end-P.nPadding), :, :);
end

mrCov = zeros([nPairs, nSpk], 'single');
trA = trWav(:,viChan1,:);
trB = trWav(:,viChan2,:);
switch lower(P.vcPairFet)
    case 'prod'
        for iSpk = 1:nSpk
            mrCov(:, iSpk) = sum(trA(:,:,iSpk) .* trB(:,:,iSpk)); 
        end
    case 'cov'
        for iSpk=1:nSpk
            mrA = trA(:,:,iSpk);
            mrB = trB(:,:,iSpk);  
            mrCov(:, iSpk) = ...
                mean(bsxfun(@minus, mrA, mean(mrA) .* ...
                    bsxfun(@minus, mrB, mean(mrB))));    

        %     mrCov(:, iSpk) = sum(trWav(:,viChan1,iSpk) .* trWav(:,viChan2,iSpk));    
        end
    case 'corr'
        for iSpk=1:nSpk
            mrA = trA(:,:,iSpk);
            mrB = trB(:,:,iSpk);       
            mrCov(:, iSpk) = ...
                mean(bsxfun(@minus, mrA, mean(mrA)) .* ...
                    bsxfun(@minus, mrB, mean(mrB))) ...
                    ./ (std(mrA) .* std(mrB));    

        %     mrCov(:, iSpk) = sum(trWav(:,viChan1,iSpk) .* trWav(:,viChan2,iSpk));    
        end
    case 'vpp'
        if P.nInterp > 1
            vrX = 1:size(trWav,1);
            vrXi = 1:(1/P.nInterp):size(trWav,1);
        end
        for iSpk=1:nSpk
            mrD = trA(:,:,iSpk) - trB(:,:,iSpk);  
            if P.nInterp > 1
                mrD = interp1(vrX, mrD, vrXi, 'spline');
            end
            mrCov(:, iSpk) = max(mrD) - min(mrD);
        end
    otherwise
        error('undefined pairFeature');
end

    