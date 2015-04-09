function [S, P] = cluster1(S, varargin)
P = funcDefStr(funcInStr(varargin{:}), ...
    'fCluster', 1, 'funcFet', [], 'fReclust', 1, 'fKeepNoiseClu', 1, ...
    'iDay', [], 'iShank', [], 'keepFraction', 1, 'fCleanClu', 1, ...
    'fNormFet', 0, 'fReclust', 0, 'Sclu', []);

if isempty(S), return; end
if ~P.fCluster, return; end

try
    
%     vcDate = getDateFromFullpath(P.cs_fname{P.iDay});
%     P.vcTitle = sprintf('%s, %s, Shank%d', P.animalID, vcDate, P.iShank);    
    S.mrFet = getFeatures(S.trSpkWav, P);
    if ~isempty(P.funcFet)
        S.mrFet = P.funcFet(S.mrFet);
    end
    if P.keepFraction < 1
        vrFet = sum(S.mrFet);
        S.viSpk = find(vrFet > quantile(vrFet, 1-P.keepFraction)); %debug
        S.mrFet = S.mrFet(:,S.viSpk); 
        S.trSpkWav = S.trSpkWav(:,:,S.viSpk);
        S.vrTime = S.vrTime(S.viSpk);
        S.mlTran = S.mlTran(S.viSpk);
    else
        S.viSpk = 1:size(S.mrFet, 2);
    end
    if P.fNormFet
        S.mrFet = bsxfun(@times, S.mrFet, 1./sqrt(sum(S.mrFet.^2)));
    end
    
   if isempty(S.Sclu) || P.fReclust
        S.Sclu = clusterScience(S.mrFet, P);
   else
        S.Sclu = guessNclu(S.Sclu, P);
   end

    if P.fCleanClu
%         if isempty(S.viSpk)
            [S.trSpkWav, S.Sclu] = cleanClu(S.trSpkWav, S.Sclu, P); 
%         else
%             [S.trSpkWav(:,:,S.viSpk), S.Sclu] = ...
%                 cleanClu(S.trSpkWav(:,:,S.viSpk), S.Sclu, P); 
%         end
    else
        S.Sclu.viChanMin = [];
    end
    if ~isempty(S.Sclu)
        S.Sclu.vrIsoDist = isoDist(S.mrFet, S.Sclu.cl);
        S.Sclu.vrIsiRatio = isiRatio(S.vrTime, S.Sclu.cl);
%         fprintf('%s, day%d, shank%d, #Clu=%d, %d/%d spikes(%0.1f%%), <isoDist>=%0.1f, <isi rat>=%0.3f\n', ...
%             P.animalID, iDay, iShank, max(S.Sclu.cl)-1, ...
%             sum(S.Sclu.cl>1), numel(S.Sclu.cl), ...
%             sum(S.Sclu.cl>1) / numel(S.Sclu.cl) * 100, ...
%             nanmean(S.Sclu.vrIsoDist(2:end)), ...
%             nanmean(S.Sclu.vrIsiRatio(2:end)));
        disp('Iso Dist:');
        disp(S.Sclu.vrIsoDist(:)');
        disp('ISI Ratio:');
        disp(S.Sclu.vrIsiRatio(:)');
    else
        S.Sclu.vrIsoDist = [];
        S.Sclu.vrIsiRatio = [];
    end    
    if ~P.fKeepNoiseClu        
        vl = S.Sclu.cl > 1;
        S.trSpkWav = S.trSpkWav(:,:,vl); %kill spike table       
        S.viSpk = S.viSpk(vl);
%         S.vrTime = S.vrTime(vl);
    end
catch err
    disp(lasterr);
end