function [mrFet, P] = getFeatures(trSpkWav, P)
% trSpkWav: nTime x nChan x nTran
%   P: {nPadding, spkLim}
P = funcDefStr(P, 'fZscore', 0, 'nPadding', 0, 'slopeLim', [-8,16], ...
    'spkLim', [-8, 12], 'viChanRef', [], 'mrSiteLoc', [], 'nPca', 6);

viSlope = (P.slopeLim(1):P.slopeLim(end)) + 1 - P.spkLim(1);

% remove padding
% if P.nPadding > 0
%     trSpkWav = trSpkWav((1+P.nPadding):(end-P.nPadding),:,:);
% else
%     trSpkWav = trSpkWav;
% end
iPeak = -P.spkLim(1)+1;
nSamples = size(trSpkWav, 1);
nChans = size(trSpkWav, 2);
nSpks = size(trSpkWav, 3);
viRange = 1:nSamples;
if P.nInterp > 1
    viRangeInt0 = 1:(1/P.nInterp):nSamples;
    viSlopeInt = viSlope(1):(1/P.nInterp):viSlope(end);
else
    viRangeInt0 = [];
    viSlopeInt = [];
end

if ~isempty(P.mrSiteLoc)
    vrXe = single(P.mrSiteLoc(1,:));
    vrYe = single(P.mrSiteLoc(2,:));
end
if P.vcFet(1) == '@'
    eval(sprintf('funcFet = %s;', lower(P.vcFet)));
    mrFet = zeros(nChans, nSpks, 'single');
    for iSpk = 1:nSpks
        mrData1 = trSpkWav(:,:,iSpk);
        if ~isempty(viRangeInt0)
            mrData1 = interp1(viRange, mrData1, ...
                viRangeInt0 , 'spline');
        end
        mrFet(:,iSpk) = funcFet(mrData1);    
    end
    return;
else
    switch lower(P.vcFet)
        case {'pairvpp', 'paircov', 'paricorr'}
            mrFet = pairFet(trSpkWav, P);
        case 'pairdot'
            mrFet = pairFet(trSpkWav, P);
        case 'pca'                            
            mrFet = getWavPca(trSpkWav, P);
        case 'phase-pca'
            mrFet = getWavPca(phasePortrait(trSpkWav, 'diffOrder', P.diffOrder), P);
        case 'phase-align-pca'
            mrFet = getWavPca(alignSpkWavXcovMultiQuick(phasePortrait(trSpkWav, 'diffOrder', 7)), P);
        case 'alignpca'                            
            mrFet = getWavPca(alignSpkWavXcovMultiQuick(trSpkWav), P.nPca,1);
        case 'alignwavtop'
            mrFet = wavtopMulti(alignSpkWavXcovMultiQuick(trSpkWav), P.nTop);
        case 'aligntrim'
            trSpkWavExt = trimSpkWav(alignSpkWavXcovMultiQuick(trSpkWav), P.trimLim);
            mrFet = reshape(trSpkWavExt, size(trSpkWavExt,1)*size(trSpkWavExt,2),[]);
        case 'aligntrimpca'
            trSpkWavExt = trimSpkWav(alignSpkWavXcovMultiQuick(trSpkWav), P.trimLim);
            mrFet = getWavPca(trSpkWavExt, P.nPca,1);
        case 'pcalat'                            
            mrFet = getWavPca(trSpkWav, 3, 1);
        case 'vpeak'
            mrFet = reshape(trSpkWav(iPeak,:,:), [nChans, nSpks]);
        case 'vppdt' %requires seuclidean
            mrFet = zeros(nChans*2, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                if ~isempty(viRangeInt0)
                    mrData1 = interp1(viRange, mrData1, ...
                        viRangeInt0 , 'spline');
                end
                [vrMax, viMax] = max(mrData1);
                [vrMin, viMin] = min(mrData1);
                mrFet(:,iSpk) = [vrMax-vrMin, viMax-viMin];
            end
            
        case 'ppp' %energy operator (slope x ampl)
            mrFet = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                mrData1 = mrData1 .* differentiate(mrData1, 3);
                if ~isempty(viRangeInt0)
                    mrData1 = interp1(viRange, mrData1, ...
                        viRangeInt0 , 'spline');
                end
                mrFet(:,iSpk) = max(mrData1) - min(mrData1);
            end
            mrFet = sqrt(mrFet);
            
        case 'intpp' %integrate peak-to-peak
            mrFet = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                mrData1 = cumsum(mrData1);
                mrFet(:,iSpk) = max(mrData1) - min(mrData1);
            end

        case 'intmindet' %integrate peak-to-peak
            mrFet = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                mrData1 = detrend(cumsum(mrData1));
                mrFet(:,iSpk) = min(mrData1);
            end

        case 'intmindet_centroid' %integrate peak-to-peak
            mrFet = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                mrData1 = detrend(cumsum(mrData1));
                mrFet(:,iSpk) = min(mrData1);
            end
            mrFet = bsxfun(@times, mrFet, 1./sqrt(sum(mrFet.^2)));
            mrFet = [zscoreMat(mrFet); 
                     zscore(getCentroidMoment(mrFet, vrXe, vrYe, 2)')'];
            
        case 'intmindet_vpp' %integrate peak-to-peak
            mrFet = zeros(nChans, nSpks, 'single');
            [mrMax, mrMin] = getMaxMin(trSpkWav, viRangeInt0);
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                mrData1 = detrend(cumsum(mrData1));
                mrFet(:,iSpk) = min(mrData1);
            end
            mrFet = [zscoreMat(mrFet); zscoreMat(mrMax-mrMin)];
            
        case 'centroidintmindet' %integrate peak-to-peak
            mrFet = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                mrData1 = detrend(cumsum(mrData1));
                mrFet(:,iSpk) = min(mrData1);
            end
            mrFet = getCentroid(mrFet, vrXe, vrYe, 2);
            
        case 'neo' %energy operator (slope x ampl)
            mrFet = zeros(nChans, nSpks, 'single');
            idx1 = -P.spkLim(1);
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
%                 mrData1 = mrData1(2:end-1,:).^2 ...
%                         - mrData1(1:end-2,:) .* mrData1(3:end,:);
%                 mrFet(:,iSpk) = max(mrData1);
                mrFet(:,iSpk) = mrData1(idx1,:).^2 - ...
                        mrData1(idx1+1,:) .* mrData1(idx1-2,:);
            end
%             mrFet = sqrt(mrFet);
            
        case 'centroidppp' %energy operator (slope x ampl)
            mrFet = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                mrData1 = mrData1 .* differentiate(mrData1, 3);
                if ~isempty(viRangeInt0)
                    mrData1 = interp1(viRange, mrData1, ...
                        viRangeInt0 , 'spline');
                end
                mrFet(:,iSpk) = max(mrData1) - min(mrData1);
            end
%             mrFet = sqrt(mrFet);
            mrFet = zscore([getCentroid(mrFet, vrXe, vrYe, .5); ...
                            getCentroid(mrFet, vrXe, vrYe, 1); ...
                            getCentroid(mrFet, vrXe, vrYe, 2)]')';
                        
        case 'pminmax' %energy operator (slope x ampl)
            mrFet = zeros(nChans*2, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                mrData1 = mrData1 .* differentiate(mrData1, 3);
                if ~isempty(viRangeInt0)
                    mrData1 = interp1(viRange, mrData1, ...
                        viRangeInt0 , 'spline');
                end
                mrFet(:,iSpk) = [max(mrData1), min(mrData1)];
            end
            
        case 'vpp'
            mrFet = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                if ~isempty(viRangeInt0)
                    mrData1 = interp1(viRange, mrData1, ...
                        viRangeInt0 , 'spline');
                end
                mrFet(:,iSpk) = max(mrData1) - min(mrData1);
            end
            %mrFet = zscore(mrFet')';
            
        case 'vppnormref'
            mrFet = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                if ~isempty(viRangeInt0)
                    mrData1 = interp1(viRange, mrData1, ...
                        viRangeInt0 , 'spline');
                end
                mrFet(:,iSpk) = max(mrData1) - min(mrData1);
                iChanRef = P.viChanRef(iSpk);
                mrFet(:,iSpk) = mrFet(:,iSpk) / mrFet(iChanRef,iSpk);
            end
            
        case 'zvppspp'
            mrFetV = zeros(nChans, nSpks, 'single');
            mrFetS = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                mrDataS = differentiate(mrData1(viSlope,:),3);
                if ~isempty(viRangeInt0)
                    mrData1 = interp1(viRange, mrData1, ...
                        viRangeInt0 , 'spline');
                    mrDataS = interp1(viSlope, mrDataS, ...
                        viSlopeInt , 'spline');
                end
                mrFetV(:,iSpk) = max(mrData1) - min(mrData1);                
                mrFetS(:,iSpk) = max(mrDataS) - min(mrDataS);                
            end
            mrFet = [(mrFetV - nanmean(mrFetV(:))) / nanstd(mrFetV(:));
                    (mrFetS - nanmean(mrFetS(:))) / nanstd(mrFetS(:))];
            P.fZscore = 0;
            
        case 'spp/vpp'
            mrFet = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                mrDataS = differentiate(mrData1(viSlope,:),3);
                if ~isempty(viRangeInt0)
                    mrData1 = interp1(viRange, mrData1, ...
                        viRangeInt0 , 'spline');
                end
                mrFet(:,iSpk) = (max(mrDataS)-min(mrDataS)) ...
                    ./ (max(mrData1) - min(mrData1));                
            end
            
        case 'vpp_spp/vpp'
            mrFet1 = zeros(nChans, nSpks, 'single');
            mrFet2 = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                mrDataS = differentiate(mrData1(viSlope,:),3);
                if ~isempty(viRangeInt0)
                    mrData1 = interp1(viRange, mrData1, ...
                        viRangeInt0 , 'spline');
                    mrDataS = interp1(viSlope, mrDataS, ...
                        viSlopeInt , 'spline');
                end
                mrFet1(:,iSpk) = max(mrData1) - min(mrData1);
                mrFet2(:,iSpk) = (max(mrDataS) - min(mrDataS)) ./...
                    mrFet1(:,iSpk)';              
            end
            mrFet = [(mrFet1 - nanmean(mrFet1(:))) / nanstd(mrFet1(:));
                    (mrFet2 - nanmean(mrFet2(:))) / nanstd(mrFet2(:))];
                
        case 'spp'
            mrFet = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrDataS = trSpkWav(:,:,iSpk);
                mrDataS = differentiate(mrDataS(viSlope,:),3);
                if ~isempty(viRangeInt0)
                    mrDataS = interp1(viSlope, mrDataS, ...
                        viSlopeInt , 'spline');
                end
                mrFet(:,iSpk) = max(mrDataS) - min(mrDataS);                
            end
            
        case 'slopemin'
            mrFet = zeros(nChans, nSpks, 'single');
            slopeLim = -P.spkLim(1)+1 + [-2, 0];
            for iSpk = 1:nSpks
                mrFet(:,iSpk) = diff(trSpkWav(slopeLim,:,iSpk));                
            end
            
            
        case 'sppt'
            mrFet = zeros(nChans, nSpks, 'single');
            slopeLim1 = -P.spkLim(1)+1 + [-2, 0];
            slopeLim2 = -P.spkLim(1)+5 + [-2, 0];
            for iSpk = 1:nSpks
                mrFet(:,iSpk) = diff(trSpkWav(slopeLim2,:,iSpk)) - ...
                    diff(trSpkWav(slopeLim1,:,iSpk));                
            end
            
        case 'vpp_sppt'
            [mrMax, mrMin] = getMaxMin(trSpkWav, viRangeInt0);
            mrVpp = [mrMax - mrMin];
            mrSpp = zeros(nChans, nSpks, 'single');
            slopeLim1 = -P.spkLim(1)+1 + [-2, 0];
            slopeLim2 = -P.spkLim(1)+5 + [-2, 0];
            for iSpk = 1:nSpks
                mrSpp(:,iSpk) = diff(trSpkWav(slopeLim2,:,iSpk)) - ...
                    diff(trSpkWav(slopeLim1,:,iSpk));                
            end
            mrFet = [zscoreMat(mrVpp);zscoreMat(mrSpp)]; 

        case 'vpp_vrat_srat'
            [mrMax, mrMin] = getMaxMin(trSpkWav, viRangeInt0);
            mrVpp = [mrMax - mrMin];
            mrSpp = zeros(nChans, nSpks, 'single');
            slopeLim1 = -P.spkLim(1)+1 + [-2, 0];
            slopeLim2 = -P.spkLim(1)+5 + [-2, 0];
            for iSpk = 1:nSpks
                mrSpp(:,iSpk) = diff(trSpkWav(slopeLim2,:,iSpk)) - ...
                    diff(trSpkWav(slopeLim1,:,iSpk));                
            end
            mrFet = [zscoreMat(mrVpp); ...
                     zscoreMat(mrMin./mrVpp); ...
                     zscoreMat(mrSpp./mrVpp)]; 

        case 'vpp_vrat'
            [mrMax, mrMin] = getMaxMin(trSpkWav, viRangeInt0);
            mrVpp = [mrMax - mrMin];
            mrFet = [zscoreMat(mrVpp); ...
                     zscoreMat(mrMin./mrVpp)]; 
                 
        case 'vpp_srat'
            [mrMax, mrMin] = getMaxMin(trSpkWav, viRangeInt0);
            mrVpp = [mrMax - mrMin];
            mrSpp = zeros(nChans, nSpks, 'single');
            slopeLim1 = -P.spkLim(1)+1 + [-2, 0];
            slopeLim2 = -P.spkLim(1)+5 + [-2, 0];
            for iSpk = 1:nSpks
                mrSpp(:,iSpk) = diff(trSpkWav(slopeLim2,:,iSpk)) - ...
                    diff(trSpkWav(slopeLim1,:,iSpk));                
            end
            mrFet = [zscoreMat(mrVpp); ...
                     zscoreMat(mrSpp./mrVpp)]; 
                 
        case 'vmin_vmax_smin_smax'
            [mrVmax, mrVmin] = getMaxMin(trSpkWav, viRangeInt0);
            mrSmin = zeros(nChans, nSpks, 'single');
            mrSmax = zeros(nChans, nSpks, 'single');
            slopeLimMin = -P.spkLim(1)+1 + [-2, 0];
            slopeLimMax = -P.spkLim(1)+5 + [-2, 0];
            for iSpk = 1:nSpks
                mrSmin(:,iSpk) = diff(trSpkWav(slopeLimMin,:,iSpk));   
                mrSmax(:,iSpk) = diff(trSpkWav(slopeLimMax,:,iSpk));
            end
            mrFet = [zscoreMat(mrVmin);zscoreMat(mrVmax); ...
                     zscoreMat(mrSmin);zscoreMat(mrSmax)];
            
        case 'sppnormref'
            mrFet = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrDataS = trSpkWav(:,:,iSpk);
                mrDataS = differentiate(mrDataS(viSlope,:),3);
                if ~isempty(viRangeInt0)
                    mrDataS = interp1(viSlope, mrDataS, ...
                        viSlopeInt , 'spline');
                end
                mrFet(:,iSpk) = max(mrDataS) - min(mrDataS);                
                iChanRef = P.viChanRef(iSpk);
                mrFet(:,iSpk) = mrFet(:,iSpk) / mrFet(iChanRef,iSpk);
            end 

        case 'zvpp+zspp'
            mrFetV = zeros(nChans, nSpks, 'single');
            mrFetS = zeros(nChans, nSpks, 'single');
            for iSpk = 1:nSpks
                mrData1 = trSpkWav(:,:,iSpk);
                mrDataS = differentiate(mrData1(viSlope,:),3);
                if ~isempty(viRangeInt0)
                    mrData1 = interp1(viRange, mrData1, ...
                        viRangeInt0 , 'spline');
                end
                mrFetV(:,iSpk) = max(mrData1) - min(mrData1);                
                mrFetS(:,iSpk) = max(mrDataS) - min(mrDataS);                
            end
            mrFet = (mrFetV - nanmean(mrFetV(:))) / nanstd(mrFetV(:)) + ... 
                    (mrFetS - nanmean(mrFetS(:))) / nanstd(mrFetS(:));
            P.fZscore = 0;
            
            
        case 'maxmin'
            [mrMax, mrMin] = getMaxMin(trSpkWav, viRangeInt0);
            mrFet = [mrMax; mrMin];
    

        case 'vpprat'
            [mrMax, mrMin] = getMaxMin(trSpkWav, viRangeInt0);
            mrVpp = mrMax - mrMin;
            mrFet = [zscoreMat(mrVpp); zscoreMat(mrMin./mrVpp)];
            
         
        case 'meanpwr'
            %[mrA, mrDT] = getVpp(trSpkWav, viRangeInt0);
            [mrMax, mrMin] = getMaxMin(trSpkWav, viRangeInt0);
            mrA = mrMax - mrMin;
            mrFet = [zscoreMat(meanPwr(mrA,1)); ...
                     zscoreMat(meanPwr(mrA,2)); ...
                     zscoreMat(meanPwr(mrA,3)); ...
                     zscoreMat(meanPwr(mrA,4))];
                     
         case 'centroid'   
            [mrMax, mrMin] = getMaxMin(trSpkWav, viRangeInt0);
            vrXe = single(P.mrSiteLoc(1,:));
            vrYe = single(P.mrSiteLoc(2,:));
            mrA = mrMax - mrMin;  
            [vrX0, vrY0, vrA0] = getSpkPos(mrA, vrXe, vrYe, .5);
            [vrX1, vrY1, vrA1] = getSpkPos(mrA, vrXe, vrYe, 1);
            [vrX2, vrY2, vrA2] = getSpkPos(mrA, vrXe, vrYe, 2);
            [vrX3, vrY3, vrA3] = getSpkPos(mrA, vrXe, vrYe, 3);
            mrFet = zscore([vrX0;vrY0;vrX1;vrY1;vrX2;vrY2;vrX3;vrY3]')';
    
         case 'centroid_moment_vpp'
            [mrMax, mrMin] = getMaxMin(trSpkWav, viRangeInt0);
            mrA = mrMax - mrMin;
            mrFet = zscore([getCentroidMoment(mrA, vrXe, vrYe, 1); ...
                            getCentroidMoment(mrA, vrXe, vrYe, 2)]')';
            mrFet = [mrFet; zscoreMat(mrA)];

        
        case 'centroid_moment'
            [mrMax, mrMin] = getMaxMin(trSpkWav, viRangeInt0);
            mrA = mrMax - mrMin;
%             mrFet = zscore([getCentroidMoment(mrA, vrXe, vrYe, .5); ...
%                             getCentroidMoment(mrA, vrXe, vrYe, 1); ...
%                             getCentroidMoment(mrA, vrXe, vrYe, 2); ...
%                             getCentroidMoment(mrA, vrXe, vrYe, 3)]')';
                        
            mrFet = zscore([getCentroidMoment(mrA, vrXe, vrYe, 3); ...
                            getCentroidMoment(mrA, vrXe, vrYe, 1); ...
                            getCentroidMoment(mrA, vrXe, vrYe, 2)]')';            
            
        case 'geometric'
            %[mrA, mrDT] = getVpp(trSpkWav, viRangeInt0);
            [mrMax, mrMin] = getMaxMin(trSpkWav, viRangeInt0);
            mrA = mrMax - mrMin;
            %mrA = abs(mrMin);
            
            %mrA = getSpp(trSpkWav, viSlope, viSlopeInt);
            %vrMaxA = max(mrA);
            %mrA = abs(getMin(trSpkWav, 1 - P.spkLim(1) + (-2:2), P.nInterp));     
            %mrA = abs(reshape(trSpkWav(-P.spkLim(1)+1,:,:), size(trSpkWav,2), []));
            
            vrXe = single(P.mrSiteLoc(1,:));
            vrYe = single(P.mrSiteLoc(2,:));
            [vrPosX0, vrPosY0, vrA0sum] = getSpkPos(mrA, vrXe, vrYe, .5);
            [vrPosX1, vrPosY1, vrA1sum] = getSpkPos(mrA, vrXe, vrYe, 1);
            [vrPosX2, vrPosY2, vrA2sum] = getSpkPos(mrA, vrXe, vrYe, 2);
            [vrPosX3, vrPosY3, vrA3sum] = getSpkPos(mrA, vrXe, vrYe, 3);
                        
            %viMat = sub2ind(size(mrMin), P.viChanRef, 1:size(mrMin,2));
            %vrRat2 = abs(mrMax(viMat)) ./ abs(mrMin(viMat)); 
            %vrRat2 = sqrt(mean(mrMin.^2)) ./ sqrt(mean(mrA.^2));
            %vrRat2 = min(mrMin) ./ max(mrA);

            mrFet = zscore([vrPosX0; vrPosY0; vrPosX1; vrPosY1; vrPosX2; vrPosY2]')'; %does this by column
            
        case 'xcov'
            mrFet = fetXcovPair(trSpkWav);
            
        case 'pcaxcov' %use 
            mrFet = fetXcovPair(pcaClean(trSpkWav, 'nPcaPerChan', P.nPcaPerChan));
            
        otherwise
            error('unsupported vcFet: %s', P.vcFet);
    end
end
end%func


function vrTmin = meanWeighted(mrTmin, mrA, n)
mrA = mrA.^n;
vrTmin = sum(mrTmin .* mrA) ./ sum(mrA);
end


function [mrMax, mrMin] = getMaxMin(trSpkWav, viRangeInt0)
if nargin < 2
    viRangeInt0 = [];
end

nSamples = size(trSpkWav, 1);
nChans = size(trSpkWav, 2);
nSpks = size(trSpkWav, 3);
viRange = 1:nSamples;

mrMax = zeros(nChans, nSpks, 'single');
mrMin = zeros(nChans, nSpks, 'single');

for iSpk = 1:nSpks
    mrData1 = trSpkWav(:,:,iSpk);
    if ~isempty(viRangeInt0)
        mrData1 = interp1(viRange, mrData1, ...
            viRangeInt0 , 'spline');
    end
    [mrMin(:,iSpk)] = min(mrData1);
    [mrMax(:,iSpk)] = max(mrData1);
end 
end %func


function [mrFet, mrDT] = getVpp(trSpkWav, viRangeInt0)
if nargin < 2
    viRangeInt0 = [];
end

nSamples = size(trSpkWav, 1);
nChans = size(trSpkWav, 2);
nSpks = size(trSpkWav, 3);
viRange = 1:nSamples;

mrFet = zeros(nChans, nSpks, 'single');
mrDT = zeros(nChans, nSpks, 'single');

for iSpk = 1:nSpks
    mrData1 = trSpkWav(:,:,iSpk);
    if ~isempty(viRangeInt0)
        mrData1 = interp1(viRange, mrData1, ...
            viRangeInt0 , 'spline');
    end
    [vrAmin1, viTmin1] = min(mrData1);
    [vrAmax1, viTmax1] = max(mrData1);
    mrFet(:,iSpk) = vrAmax1 - vrAmin1;
    mrDT(:,iSpk) = viTmax1 - viTmin1;
end 
end %func


%% around the min peak
function mrFet = getMin(trSpkWav, viRange, nInterp)
if nargin < 2
    viRange = 1:size(trSpkWav,1);
end
if nargin < 3
    viRange1Int = [];
else
    viRange1Int = 1:(1/nInterp):numel(viRange);
    viRange1 = 1:numel(viRange);
end

nChans = size(trSpkWav, 2);
nSpks = size(trSpkWav, 3);
mrFet = zeros(nChans, nSpks, 'single');
for iSpk = 1:nSpks
    mrData1 = trSpkWav(viRange,:,iSpk);
    if ~isempty(viRange1Int)
        mrData1 = interp1(viRange1, mrData1, viRange1Int , 'spline');
    end
    mrFet(:,iSpk) = min(mrData1);
end 
end %func


function mrFet = getSpp(trSpkWav, viSlope, viSlopeInt)
if nargin < 3
    viSlopeInt = [];
end

nChans = size(trSpkWav, 2);
nSpks = size(trSpkWav, 3);

mrFet = zeros(nChans, nSpks, 'single');
for iSpk = 1:nSpks
    mrDataS = trSpkWav(:,:,iSpk);
    mrDataS = differentiate(mrDataS(viSlope,:),3);
    if ~isempty(viSlopeInt)
        mrDataS = interp1(viSlope, mrDataS, ...
            viSlopeInt , 'spline');
    end
    mrFet(:,iSpk) = max(mrDataS) - min(mrDataS);                
end
end %func


function [vrX, vrY, vrAsum] = getSpkPos(mrA, vrXe, vrYe, n)
mrA = mrA.^n;
vrAsum = sum(mrA);
vrX = sum(bsxfun(@times, mrA, vrXe(:))) ./ vrAsum;
vrY = sum(bsxfun(@times, mrA, vrYe(:))) ./ vrAsum;
vrAsum = vrAsum .^ (1/n);
end


function mr = zscoreMat(mr)
mr = (mr - nanmean(mr(:))) / nanstd(mr(:));
end


function vr = meanPwr(mr, n)
mr = bsxfun(@minus, mr, mean(mr));
mr = mr .^ n;
vr = mean(mr) .^ (1/n);
end


function mr = getCentroidMoment(mrA, vrXe, vrYe, n)
[vrX, vrY, vrA] = getSpkPos(mrA, vrXe, vrYe, n);
[vrX2, vrY2] = getSpkPos(mrA, vrXe.^2, vrYe.^2, n);
vrX2 = sqrt(vrX2 - vrX.^2);
vrY2 = sqrt(vrY2 - vrY.^2);
mr = [vrX; vrY; vrX2; vrY2];
end


function mr = getCentroid(mrA, vrXe, vrYe, n)
[vrX, vrY, vrA] = getSpkPos(mrA, vrXe, vrYe, n);
mr = [vrX; vrY];
end