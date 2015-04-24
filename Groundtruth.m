classdef Groundtruth
    properties
        % import paramter
        csFnames;
        iChInt = 3; %intracell chan number.
        viChExt = [1,2,4];
        nInterp = 10;
        freqLim = [300, .95*10000];
%         freqLim = [300 3000];
        cmWav;
        Sfile;
        fMerge = 0;
        fSpont = 1;
        timeLim = [];
        fPlot = 1;
        sRateHz;
        vcDataset;
        sgOrder = 5;
        sgPoly = 4;
        
        % detection
        minInterval;
        peakThresh = 0;
        nLimInt = [];
        nLimExt = [];
        tLimInt = [-0.0012, 0.0008];
        tLimExt = [-.0008, .0012];
        cvSpkInt;
        cvSpkExt;
        ctSpkWavInt;
        ctSpkWavExt;
        vcDetect = 'min';
        qqFactor = 4;
        nPadding = 10;
        
        %alignment
        fAlign = 1;
        fReclust = 0;
        fRealignClu = 0;
        alignPower = 1;
        fAlignAfterPhase = 0;

        %feature
        vcFet = 'pcamulti';
        nLags = 3;
        nPca = 3;
        cmFetExt;
        fLatent = 0;
        fNormFet = 0;
        nTop = 5; 
        fPhaseMag = 0;
        fSquare = 0;
        fRescale = 1;
        trimLim = [];
        nTrim = 4;
        fSmooth = 1;
        fPcaMulti = 1;
        fPhaseSmooth = 0;
        
        %cluster
        vcClu = 'science';
        cvClu;
        fZscore = 0;
        vcDist = 'cosine';
        cluPct = .2;
        diffOrder = 3;
        spkRemoveZscore = [];
        fCleanup = 1;
        
        %eval
        vrHit;
        vrTrue;
        vnClu;
        fDiffPair = 0;
    end
    
    methods
        function obj = Groundtruth(csFnames, varargin)      
            obj = obj.loadDataset(csFnames); %load by keywords
            obj = obj.setFields(varargin{:});
        end %func
        
        
        function obj = loadDataset(obj, vcDataset)
            switch lower(computer('arch'))
                case 'maci64'
                    vcDir = '/Users/junj10/Dropbox (HHMI)/MladenTritrodePatchData/01092013/';
                case 'win64'
                    vcDir = 'D:\Dropbox (HHMI)\MladenTritrodePatchData\01092013\';
            end
            if iscell(vcDataset)
                obj.csFnames = vcDataset;
                return;
            end
            switch lower(vcDataset)
                case 'spontall'
                    obj.csFnames = vcDir;
                    obj.fSpont = 1;
                    obj.fMerge = 1;
                    obj.timeLim = [];
                case 'spont2'
                    csFiles = {'bp2012_0105.abf', 'bp2012_0106.abf'};
                    obj.csFnames = combinePath(vcDir, csFiles);
                    obj.fSpont = 1;
                    obj.fMerge = 1;
                    obj.timeLim = [];
                case 'spont'
                    csFiles = {'bp2012_0113.abf', 'bp2012_0117.abf', 'bp2012_0119.abf'};
                    obj.csFnames = combinePath(vcDir, csFiles);
                    obj.fSpont = 1;
                    obj.fMerge = 1;
                    obj.timeLim = [];
                case 'driven'
                    csFiles = {'bp2012_0102.abf', 'bp2012_0103.abf'};
                    obj.csFnames = combinePath(vcDir, csFiles);
                    obj.fSpont=0;
                    obj.fMerge = 1;
                    obj.timeLim = [ ];
                case 'driven30'
                    csFiles = {'bp2012_0102.abf', 'bp2012_0103.abf'};
                    obj.csFnames = combinePath(vcDir, csFiles);
                    obj.fSpont=0;
                    obj.fMerge = 1;
                    obj.timeLim = [0 30];
                otherwise
                    obj.csFnames = vcDataset;
            end
        end

        
        function [obj, P] = setFields(obj, varargin)
            P = funcInStr(varargin{:});
            csFields = fieldnames(P);
            for iField=1:numel(csFields)
                try
                    eval(sprintf('obj.%s = P.%s;', ...
                        csFields{iField}, csFields{iField}));
                catch err
                    disp('setFields, P->obj');
                    disp(csFields{iField});
                end
            end
            if nargout >= 2
                csFields = fieldnames(obj);
                for iField=1:numel(csFields)
                    try
                        eval(sprintf('P.%s = obj.%s;', ...
                            csFields{iField}, csFields{iField}));
                    catch err
%                         disp('setFields, obj->P');
%                         disp(csFields{iField});
                    end
                end
            end
        end
        
        
        function obj = import(obj, varargin)
            [obj, P] = obj.setFields(varargin{:});
            
            [obj.cmWav, obj.Sfile, obj.csFnames] = importAbf(obj.csFnames, ...
                'freqLim', obj.freqLim, 'fMerge', obj.fMerge, ...
                'fSpont', obj.fSpont, 'fPlot', obj.fPlot, 'timeLim', obj.timeLim);    
            if obj.fSmooth
                obj.cmWav = filterSG(obj.cmWav, obj.sgOrder, obj.sgPoly);
            end
            obj.cmWav = interpSpline(obj.cmWav, obj.nInterp);
            if ~iscell(obj.cmWav)
                obj.cmWav = {obj.cmWav};
            end
            if ~iscell(obj.Sfile)
                obj.Sfile = {obj.Sfile};                
            end
            obj.sRateHz = obj.Sfile{1}.sRateHz * obj.nInterp;
        end
        
        
        function plot(obj)
            nFiles = numel(obj.cmWav);
            for iFile = 1:nFiles
                trSpkWavInt = obj.ctSpkWavInt{iFile};
                trSpkWavExt = obj.ctSpkWavExt{iFile};
                fname = obj.csFnames{iFile};
                P1.csTitles = {'Int', 'EC1', 'EC2', 'EC3'};
                P1.grid = 'on';
                P1.title = sprintf('%s, intracell, n=%d', ...
                    fname, size(trSpkWavInt,3));

                figure; trPlot(trSpkWavInt, P1);
                
                P2=P1;
                P2.title = sprintf('%s, extracell, n=%d', ...
                    fname, size(trSpkWavExt,3));
                figure; trPlot(trSpkWavExt, P2);           
            end
        end
        
        
        function plotClu(obj, varargin)
            P = funcDefStr(funcInStr(varargin{:}), ...
                'nSpkMax', 100, 'maxAmp', .5);
            for iFile = 1:numel(obj.ctSpkWavExt)
                S.trSpkWav = obj.ctSpkWavExt{iFile};
                S.trSpkWav = S.trSpkWav(:,2:end,:);
                S.Sclu.cl = obj.cvClu{iFile};
                P.spkLim = round(obj.tLimExt * obj.sRateHz);
                P.nPadding = obj.nPadding;
                figure; plotWaveform(S, P)
            end
        end
        
        
        function obj = detect(obj, varargin)
            [obj, P] = obj.setFields(varargin{:});
            nFiles = numel(obj.cmWav);
            obj.cvSpkInt = cell(nFiles,1);
            obj.cvSpkExt = cell(nFiles,1);
            obj.ctSpkWavInt = cell(nFiles,1);
            obj.ctSpkWavExt = cell(nFiles,1);
            obj.nLimInt = round(obj.tLimInt * obj.sRateHz) + obj.nPadding*[-1,1];
            obj.nLimExt = round(obj.tLimExt * obj.sRateHz) + obj.nPadding*[-1,1];
            for iFile = 1:nFiles
                mrWav = obj.cmWav{iFile};                
                viSpkInt = peakDetector(mrWav(:,obj.iChInt), 'fPlot', obj.fPlot, ...
                    'peakThresh', obj.peakThresh, 'minInterval', obj.minInterval);                    
                [trSpkWavInt, viSpkInt] = waveformTrig(mrWav(:, [obj.iChInt, obj.viChExt]), viSpkInt, obj.nLimInt);
                
                vrWavExt = sum(mrWav(:,obj.viChExt),2);
                extSpkThresh = qqThresh(vrWavExt, obj.qqFactor);
                fprintf('extSpkThresh(sum)=%f\n', extSpkThresh);
                switch lower(obj.vcDetect)
                    case 'summin'
                    viSpkExt = detectMin(vrWavExt, 'thresh', -extSpkThresh, 'fPlot', obj.fPlot, 'minInterval', obj.minInterval, 'fSum', 1);
                    case 'sumpeak'
                    viSpkExt = peakDetector(-vrWavExt, ...
                        'fPlot', 0, 'peakThresh', extSpkThresh, 'minInterval', obj.minInterval);
                    case 'min'
                    viSpkExt = detectMin(mrWav(:,obj.viChExt), 'fPlot', obj.fPlot, 'minInterval', [], 'fSum', 0, 'sRateHz', obj.sRateHz, 'qqFactor', obj.qqFactor);    
                    case 'minalign'
                    viSpkExt = detectMin(mrWav(:,obj.viChExt), 'fPlot', obj.fPlot, 'minInterval', [], 'fSum', 0, 'sRateHz', obj.sRateHz,'fAlign', 1);  
                end
                [trSpkWavExt, viSpkExt] = waveformTrig(mrWav(:,[obj.iChInt, obj.viChExt]), viSpkExt, obj.nLimExt);

                obj.ctSpkWavExt{iFile} = trSpkWavExt;
                obj.cvSpkExt{iFile} = viSpkExt;
                obj.ctSpkWavInt{iFile} = trSpkWavInt;
                obj.cvSpkInt{iFile} = viSpkInt;
            end
            if obj.fPlot
                obj.plot();
            end
        end
        
        
        function obj = getFet(obj, varargin)
            [obj, P] = obj.setFields(varargin{:});
            for iFile = 1:numel(obj.ctSpkWavExt)
                if ~isempty(obj.cvClu) && P.fRealignClu
                    viClu = obj.cvClu{iFile}; %for recursive alignment
                else
                    viClu = [];
                end
                trSpkWavExt = obj.ctSpkWavExt{iFile};                
                if obj.fAlign && ~obj.fAlignAfterPhase %align and save spike table
                    trSpkWavExt = alignXcovMulti(trSpkWavExt, ...
                        'alignPower', obj.alignPower, 'viChan', 2:size(trSpkWavExt,2), ...
                        'viClu', viClu, 'nPadding', obj.nPadding, 'fPlot', P.fPlot, 'alignPct', P.alignPct); 
                    obj.ctSpkWavExt{iFile} = trSpkWavExt; %save for later
                end
                trSpkWavExt = trSpkWavExt(:,2:end,:); 
                % Trim the padding for feature calculation
                if obj.fDiffPair
                    trSpkWavExt = diffPair(trSpkWavExt);
                end
                if obj.fPhaseMag
                    trSpkWavExt = phasePortrait(trSpkWavExt, ...
                        'diffOrder', obj.diffOrder, 'fRescale', obj.fRescale, ...
                        'fSquare', obj.fSquare, 'fPhaseSmooth', obj.fPhaseSmooth);
                end
                if obj.fAlignAfterPhase %align and save spike table
                    trSpkWavExt = alignXcovMulti(trSpkWavExt, ...
                        'alignPower', obj.alignPower, 'viChan', 2:size(trSpkWavExt,2), ...
                        'viClu', viClu, 'nPadding', obj.nPadding, 'fPlot', P.fPlot, 'alignPct', .9); 
                end
                switch lower(obj.vcFet)
                    case 'nnmf-multi'
                        disp('nnmf-multi');
                        options = statset('Display', 'iter');
                        mrFetExt = nnmf(tr2mr(trSpkWavExt)', obj.nPca*size(trSpkWavExt,2), 'options', options)';
                    case 'wav'
                        mrFetExt = reshape(trSpkWavExt, ...
                            size(trSpkWavExt,1) * size(trSpkWavExt,2), []);
                    case 'wavtop'
                        mrFetExt = wavtop(trSpkWavExt, P.nTop);
                    case 'wavtopmulti'
                        mrFetExt = wavtopMulti(trSpkWavExt, P.nTop);
                    case 'trim'
                        trSpkWavExt = trimSpkWav(trSpkWavExt, P.trimLim);
                        mrFetExt = reshape(trSpkWavExt, size(trSpkWavExt,1)*size(trSpkWavExt,2),[]);
                    case 'trimcv'
                        trSpkWavExt = trimSpkWav(trSpkWavExt, P.trimLim);
                        mrFetExt = [reshape(sqrt(mean(trSpkWavExt.^2,1)), size(trSpkWavExt,2), []) ; ...
                                    reshape(mean(trSpkWavExt,1), size(trSpkWavExt,2), [])];
                    case 'trimdiff'
                        trSpkWavExt = differentiate(trimSpkWav(trSpkWavExt, P.trimLim), obj.diffOrder, 1);
                        mrFetExt = reshape(trSpkWavExt, size(trSpkWavExt,1)*size(trSpkWavExt,2),[]);
                    case 'trimsq'
                        trSpkWavExt = log(abs(trimSpkWav(trSpkWavExt, P.trimLim)));
                        mrFetExt = reshape(trSpkWavExt, size(trSpkWavExt,1)*size(trSpkWavExt,2),[]);
                    case 'trimpca'
                        mrFetExt = getWavPca(trimSpkWav(trSpkWavExt, P.trimLim), obj.nPca, obj.fLatent);
                    case 'wavclean'
%                         mrFetExt = pcaClean(mrFetExt);
                        trSpkWavExt = pcaClean(trSpkWavExt);
                        mrFetExt = reshape(trSpkWavExt, ...
                            size(trSpkWavExt,1) * size(trSpkWavExt,2), []);
                    case 'vpp' %70%
                        mrFetExt = fetVpp(trSpkWavExt, 'fZccore', obj.fZscore);
                    case 'vppdiff' %70%
                        mrFetExt = fetVpp(diffPair(trSpkWavExt), 'fZccore', obj.fZscore);
                    case 'xcov_vpp'
                        mrFetExt = [fetXcovPair(trSpkWavExt, 'nLags', obj.nLags, 'fZscore', obj.fZscore); ...
                                        fetVpp(trSpkWavExt, 'fZccore', 1)];
                    case 'xcov_pcamultivpp'
                        mrFetExt = [fetXcovPair(trSpkWavExt, 'nLags', obj.nLags, 'fZscore', obj.fZscore); ...
                                        fetPcaMultiVpp(trSpkWavExt, 6, 'fZccore', obj.fZscore)];
                    case 'xcov_pca'
                        mrFetExt = [fetXcovPair(trSpkWavExt, 'nLags', obj.nLags, 'fZscore', obj.fZscore); ...
                                        zscoreMtx(getWavPca(trSpkWavExt, obj.nLags))];
                    case 'pca'
                        mrFetExt = getWavPca(trSpkWavExt, P);
                    case 'ica'
                        mrFetExt = trIca(trSpkWavExt, P);
                    case 'ppca'
                        mrFetExt = getWavPpca(trSpkWavExt, P);
                    case 'pcayyp'
                        [trSpkWavExtDif, trSpkWavExt] = differentiate(trSpkWavExt, P.diffOrder);
                        mrFetExt = [getWavPca(trSpkWavExt, obj.nPca, obj.fLatent); ...
                                    getWavPca(trSpkWavExtDif, obj.nPca, obj.fLatent)];
                    case 'detpca'
                        trSpkWavExt = detrendTr(trSpkWavExt);
                        mrFetExt = getWavPca(trSpkWavExt, obj.nPca, obj.fLatent);
                    case 'diffpca'
                        trSpkWavExt = differentiate(trSpkWavExt,3);
                        mrFetExt = getWavPca(trSpkWavExt, obj.nPca, obj.fLatent);
                    case 'intpca'
%                         trSpkWavExt = intDetTr(trSpkWavExt);
                        trSpkWavExt = cumsum(trSpkWavExt,1);
                        mrFetExt = getWavPca(trSpkWavExt, obj.nPca, obj.fLatent);
                    case 'neopca'
                        trSpkWavExt = alignSpkWav(trSpkWavExt, 'iMax', 8);
                        mrFetExt = getWavPca(calcNeo(trSpkWavExt), obj.nPca, obj.fLatent);
                    case 'alignpca'
                        mrFetExt = getWavPca(alignSpkWavXcov(trSpkWavExt), obj.nPca, obj.fLatent);
                    case 'pcasum'
                        mrFetExt = getWavPca(sumPair(trSpkWavExt), obj.nPca);
                    case 'pcacontrast'
                        mrFetExt = getWavPca(contrastPair(trSpkWavExt), obj.nPca);
                    case 'pcavpp'
                        mrFetExt = fetPcaVpp(trSpkWavExt, 4, 'fZscore', 1, 'hFunc', @(x)abs(min(x)));
                    case 'pcamultivpp'
                        mrFetExt = fetPcaMultiVpp(trSpkWavExt, 6, 'fZscore', obj.fZscore, 'hFunc',  []);
                    case 'pcaxcov'
                        P = struct('nLags', obj.nLags, 'fZscore', 0);
                        P.cvChanPair = {[2,3], [2,4], [3,4]};
                        mrFetExt = fetXcovPair(pcaClean(trSpkWavExt, 'nPca', obj.nPca), P);
                    case 'xcov'
                        P = struct('nLags', obj.nLags, 'fZscore', 0);
%                         P.cvChanPair = {[2,3], [2,4], [3,4]};
                        mrFetExt = fetXcovPair(trSpkWavExt, P);
                    case 'pcaxcv'
                        mrFetExt = buildXcvFet(trSpkWavExt, 'nPca', obj.nPca, 'nLag', obj.nLags);
                    case 'xcv'
                        mrFetExt = buildXcvFet(trSpkWavExt, 'nLag', obj.nLags);
                end %switch
%                 if obj.fZscore
%                     mrFetExt = zscoreMtx(mrFetExt);
% %                     mrFetExt = zscore(mrFetExt')';
%                 end
                if obj.fNormFet
                    mrFetExt = bsxfun(@times, mrFetExt, 1./sqrt(sum(mrFetExt.^2)));
                end
                obj.cmFetExt{iFile} = mrFetExt;
            end
        end
        
        
        function obj = cluster(obj, varargin)
            [obj, P] = obj.setFields(varargin{:});
            nFiles = numel(obj.cmFetExt);
            
            obj.cvClu = cell(nFiles,1);
            for iFile = 1:numel(obj.cmFetExt)
                mrFetExt = obj.cmFetExt{iFile};
                switch lower(obj.vcClu)
                    case 'science'
                        Sclu = clusterScience(mrFetExt, 'vcDist', obj.vcDist, 'fAskUser', 1, 'subsample', 1, 'percent', obj.cluPct);
                        viClu = Sclu.cl;
                    case 'klustakwik'
                        viClu = KCluster(mrFetExt');
                    case 'meanshift'
                        viClu = meanshift(mrFetExt');
                end
                if P.fCleanup
                    trSpkWavExt = obj.ctSpkWavExt{iFile};
                    [trSpkWavExt, Sclu] = ...
                        cleanClu(trSpkWavExt, viClu, 'viChan', 2:size(trSpkWavExt,2), ...
                        'nPadding', obj.nPadding, 'spkLim', round(obj.tLimExt * obj.sRateHz), ...
                        'iCluNoise', 0, 'spkRemoveZscore', obj.spkRemoveZscore);            
                    obj.ctSpkWavExt{iFile} = trSpkWavExt;
                    viClu = Sclu.cl;
                end                
                obj.cvClu{iFile} = viClu;
            end
        end
        
        
        function obj = reclust(obj, varargin)
            [obj, P] = obj.setFields(varargin{:});
            
            disp('First clustering evaluation:');
            obj.eval();
            P1 = P;
            P1.fReclust = 0;
            P1.fAlign = 0;
            obj = obj.getFet(P1);
            obj = obj.cluster(P1);
            disp('Second clustering evaluation:');
            obj.eval();
        end
        
        
        function obj = eval(obj, varargin)
            [obj, P] = obj.setFields(varargin{:});
            nFiles = numel(obj.cvClu);
            vrHit = zeros(nFiles,1);
            vrTrue = zeros(nFiles,1);
            vnClu = zeros(nFiles,1);
            for iFile=1:nFiles
                viClu = obj.cvClu{iFile};
                trSpkWavInt = obj.ctSpkWavInt{iFile};
                trSpkWavExt = obj.ctSpkWavExt{iFile};
                
                %average of the best detection
                vnSpk = [];
                nExtSpkTot = sum(toVec(trSpkWavExt(round(end/2),1,:) > -20));
                nIntSpkTot = sum(toVec(trSpkWavInt(round(end*.75),1,:) > -20));
                vnIntSpkHit = [];
                vnClu(iFile) = max(viClu);
                % vrRef = std(pdist([mrFetInt], vcDist));
                for iClu=1:vnClu(iFile)
                    vl = viClu==iClu;
                    vnSpk(iClu) = sum(vl);
                    vnIntSpkHit(iClu) = sum(toVec(trSpkWavExt(round(end/2),1,vl) > -20));
                end
                [nIntSpkHit, iCluMax] = max(vnIntSpkHit);
                fprintf('iCluMax: %d, capture prob:%0.3f\n', iCluMax, nExtSpkTot/nIntSpkTot);
                vrHit(iFile) = nIntSpkHit / nIntSpkTot;
                vrTrue(iFile) = nIntSpkHit / vnSpk(iCluMax);
                disp(iCluMax)
            end %for
            meanHit = nanmean(vrHit(:));
            meanTrue = nanmean(vrTrue(:));
            fprintf('<hit-rate>: %0.1f, <precision>: %0.1f, <c*a>: %0.1f\n', meanHit*100, meanTrue*100, meanHit*meanTrue*100);
            %disp('completeness');
            %disp(vrHit(:)');
            %disp('accuracy');
            %disp(vrTrue(:)');            
            obj.vrHit = vrHit;
            obj.vrTrue = vrTrue;
            obj.vnClu = vnClu;
%             disp(obj);
        end %func
        
        
        function obj = auto(obj, varargin)
            disp('Importing');
            obj = obj.import(varargin{:});
            disp('detect');
            obj = obj.detect(varargin{:});
            disp('getFet');
            obj = obj.getFet(varargin{:});
            disp('cluster');
            obj = obj.cluster(varargin{:});
            disp('eval');
            obj = obj.eval(varargin{:});
        end %func
        
        
        function obj = test(obj, varargin)
            disp('getFet');
            obj = obj.getFet(varargin{:});
            disp('cluster');
            obj = obj.cluster(varargin{:});
            disp('eval');
            obj = obj.eval(varargin{:});
        end
        
        
        function mr = traceInt(obj,iFile,iChan)
            trSpkWavInt = obj.ctSpkWavInt{iFile};
            mr = tr2mr(trSpkWavInt, iChan);
        end
        
        function mr = traceExt(obj,iFile,iChan)
            trSpkWavExt = obj.ctSpkWavExt{iFile};
            mr = tr2mr(trSpkWavExt, iChan);
        end
    end
    
end %classdef