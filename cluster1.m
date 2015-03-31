function S = cluster1(S, iDay, iShank, P)
if ~isfield(P, 'fCluster'), P.fCluster = 1; end
if ~isfield(P, 'funcFet'), P.funcFet = []; end
if ~isfield(P, 'fReclust'), P.fReclust = 1; end

if isempty(S), return; end
if ~P.fCluster, return; end


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
        case 'peakmin'
            mrFet = [S.mrPeak; S.mrMin];
        case 'min'
            mrFet = [S.mrMin];
        otherwise
            error('undefined fet');
    end
    if ~isempty(P.funcFet)
        mrFet = P.funcFet(S.mrPeak);
    end
    if P.fNormFet
        mrFet = bsxfun(@times, mrFet, 1./sqrt(sum(mrFet.^2)));
    end
    
   % if isempty(P.cluFraction) || P.cluFraction == 1
   if isempty(S.Sclu) || P.fReclust
        S.Sclu = clusterScience(mrFet, P);
   else
        S.Sclu = guessNclu(S.Sclu, P);
   end
%     else
%         S.Sclu.cl = ones(size(mrFet,1), 1);
%         S.Sclu.rho = zeros(size(mrFet,1), 1);
%         S.Sclu.delta = zeros(size(mrFet,1), 1);
%         vrFet = sum(mrFet.^2);
%         viFet1 = find(vrFet > quantile(vrFet, 1-P.cluFraction));
%         Sclu1 = clusterScience(mrFet(:,viFet1), P);
%         S.Sclu.cl(viFet1) = Sclu1.cl;
%         S.Sclu.cl(S.Sclu.cl<1) = 1;
%         S.Sclu.rho(viFet1) = Sclu1.rho;
%         S.Sclu.delta(viFet1) = Sclu1.delta;
%         S.Sclu.icl = viFet1(Sclu1.icl);
%     end
    if P.fCleanClu
        [S.trSpkWav, S.Sclu] = cleanClu(S.trSpkWav, S.Sclu, P); 
    else
        S.Sclu.viChanMin = [];
    end
    if ~isempty(S.Sclu)
        S.Sclu.vrIsoDist = isoDist(mrFet, S.Sclu.cl);
        S.Sclu.vrIsiRatio = isiRatio(S.vrTime, S.Sclu.cl);
    else
        S.Sclu.vrIsoDist = [];
        S.Sclu.vrIsiRatio = [];
    end    

catch err
    disp(lasterr);
end