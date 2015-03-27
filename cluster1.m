function S = cluster1(S, iDay, iShank, P)
if isempty(S), return; end

try
    vcDate = getDateFromFullpath(P.cs_fname{iDay});

    P.vcTitle = sprintf('%s, %s, Shank%d', P.animalID, vcDate, iShank);

    switch lower(P.vcFet)
        case 'peak'
            mrFet = S.mrPeak;
        case 'pca'                            
            mrFet = getWavPca(S.trSpkWav, 3);
        case 'cov'
            mrFet = S.mrCov;
    end
    if P.fNormFet
        mrFet = bsxfun(@times, mrFet, 1./sqrt(sum(mrFet.^2)));
    end
    S.Sclu = clusterScience(mrFet, P); 
    if P.fCleanClu
        [S.Sclu.cl, S.trSpkWav, S.Sclu.viChanMin] = cleanClu(S.trSpkWav, S.Sclu.cl, P); 
    else
        S.Sclu.viChanMin = [];
    end
    if ~isempty(S.Sclu)
        S.vrIsoDist = isoDist(mrFet, S.Sclu.cl);
        S.vrIsiRatio = isiRatio(S.vrTime, S.Sclu.cl);
    else
        S.vrIsoDist = [];
        S.vrIsiRatio = [];
    end    

catch err
    disp(lasterr);
end