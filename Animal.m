classdef Animal
    %ANIMAL remembers animal specific info
    properties (Constant)
        csAnimals = {'ANM282996', 'ANM279097', 'ANM279094', 'ANM286577', ...
            'ANM286578', 'ANM287075', 'ANM287074', 'ANM292757'};
        cvShankChanNlx = {(16:-1:1), (27:-1:17), (48:-1:33), (59:-1:49)}; 
    end
    
    properties
        animalID;
        implantStyle;
        probeType;
        dateImplanted;
        cs_fname; %location of files
        csXTickLabel;
        cvShankChan; %bottom-up order, left-right alternate
        cvShankImp;
        vnChanOffset = []; %offset of channels per file
        impedance;
        nShanks;
        nChans = 64;
        readDuration;
        testField;
        nDays;
        
        % Spike stats
        ccSpkVpp;
        ccSpkTime;
        cvSpkThresh;
        mrSpkAmp90;
        mnSpkCnt;
        
        % getFet
        cmFet; %cell of cell of struct
        viShank; 
        viDay;        
        freqLim = [500, 6000]; 
        spkLim = [-8, 12]; 
        vcPeak = 'min'; %feature to detect
        vcFet = 'vpp'; 
        vcDist = 'seuclidean'; 
        maxAmp = 1000; % in uV
        nInterp = 4; 
        thresh = [2 4]; %2 and 4 SD
        nPadding = 8; %number of samples to pad around spkLim
        fMeanSubt = 0;  %0
        fUseSubThresh = 0; 
        fParfor = 0; 
        fPeak = 1; 
        keepFraction = 1;
        cmWavRef; %common average conversion
        fDiffPair = 1; %differential recording
        fMeasureEvent = 0;
        
        % cluster
        fCleanClu = 1; 
%         fAskUser = 0; 
        fShowWaveform = 1; 
        SIGMA_FACTOR = 6; 
        fHalo = 0; 
        fNormFet = 0; 
        nClu; % clusterScience settings
        spkRemoveZscore = 3; % remove waveform 
        cluFraction = 1; %keep all clus
        funcFet = [];
        MAX_RHO_RATIO = 1/8;
        maxChanDiff = [];
        fKeepNoiseClu = 1;
        
        % Display
        nSpkMax = 100; %display 100 random        
    end
    
    methods
        function obj = Animal(animalID, varargin)
            [obj, P] =  obj.setFields(varargin{:});
            obj.animalID = animalID;
            if nargin == 0                
                error('Choose animals: %s', cell2mat(Animal.csAnimals));
            end
%             P = struct(varargin{:});
%             obj.animalID = animalID;
            obj.impedance = Impedance(animalID);
            
            switch obj.animalID
                case 'ANM282996'
                    obj.dateImplanted = '1/6/2015';
                    obj.implantStyle = 'RICHP';
                    obj.probeType = 'IMECI';

                case 'ANM279097' %correct pedot orientation
                    obj.dateImplanted = '1/12/2015';
                    obj.implantStyle = 'HOLTZMANT';
                    obj.probeType = 'PEDOT';

                case 'ANM279094' %correct pedot orientation (1/13)
                    obj.dateImplanted = '1/13/2015';
                    obj.implantStyle = 'HOLTZMANT';
                    obj.probeType = 'PEDOT';

                case 'ANM286577' %flip TiN alive (1/15)
                    obj.dateImplanted = '1/15/2015';
                    obj.implantStyle = 'HOLTZMANT';
                    obj.probeType = 'IMECI';

                case 'ANM286578' %flip TiN (1/20)
                    obj.dateImplanted = '1/20/2015';
                    obj.implantStyle = 'HOLTZMANT';
                    obj.probeType = 'IMECI';
                    
                case 'ANM287075'
                    obj.dateImplanted = '2/20/2015';
                    obj.implantStyle = 'RICHP';
                    obj.probeType = 'PEDOT';

                case 'ANM287074'
                    obj.dateImplanted = '2/27/2015';
                    obj.implantStyle = 'RICHP';
                    obj.probeType = 'PEDOT';
                     
                case 'ANM292757'
                    obj.dateImplanted = '3/10/2015';
                    obj.implantStyle = 'RICHP';
                    obj.probeType = 'IMECI';
                     
                otherwise
                    error('Invalid AnimalID');
            end %switch
%             
%             if isempty(obj.vnChanOffset)
%                 obj.vnChanOffset = zeros(size(obj.cs_fname)); 
%             end

            % channels in bottom-up order
            switch obj.probeType
                case 'IMECI'
                    switch obj.implantStyle
                        case 'HOLTZMANT' %flip TiN, geometry unmatched
                            obj.cvShankChan = {1+[8 9 10 11 12 13 19 14 20 15 21 16 22 17 23 18], ... 
                                1+[6 5 0 4 31 3 30 2 29 1 28], ...
                                1+[51:55, 35 61 34 60 33 59 32 58 63 57 62], ...
                                1+[40 41 46 42 47 43 48 44 49 45 50]}; 
                        case 'RICHP' %correct geometry
                            obj.cvShankChan = {1+[24:29,3,30,4,31,5,0,6,1,7,2], ... 
                                1+[22 21 16 20 15 19 14 18 13 17 12], ...
                                1+[35:39, 51 45 50 44 49 43 48 42 47 41 46], ...
                                1+[56 57 62 58 63 59 32 60 33 61 34]};
                        otherwise
                            error('Animal-Invalid implantStyle: %s', obj.implantStyle);
                    end %switch
                    %nanoz is correctly mounted
                    obj.cvShankImp = {[1:6 12 7 13 8 14 9 15 10 16 11], ...
                        [18 19 24 20 25 21 26 22 27 23 28], ...
                        [12:16 21 27 22 28 23 29 24 30 25 31 26]+40, ...
                        [1 2 7 3 8 4 9 5 10 6 11]+40};
                    
                case 'PEDOT'
                    %recording orientations correct for both
                    obj.cvShankChan = {... %correct geometry
                        1+[16 31 17 30 18 29 26 19 22 28 25 20 23 27 24 21], ...
                        1+[5 11 2 4 14 12 1 3 15 13 0], ...
                        1+[45 33 46 32 47 63 60 48 51 62 59 49 52 61 58 50], ...
                        1+[39 40 36 38 43 41 35 37 44 42 34]};
                    switch obj.implantStyle %geometry unmatched
                        case 'HOLTZMANT' %flip nanoz
                            obj.cvShankImp = {[9 25 10 26 11 27 30 12 15 28 31 13 16 29 32 14], ...
                                [19 4 22 20 7 5 23 21 8 6 24], ...
                                [6 23 7 24 8 25 28 9 12 26 29 10 13 27 30 11]+40, ...
                                [17 1 20 18 4 2 21 19 5 3 22]+40}; %nanoz correct
                        case 'RICHP' %correct
                            obj.cvShankImp = {[24 8 23 7 22 6 3 21 18 5 2 20 17 4 1 19], ...
                                [14 29 11 13 26 28 10 12 25 27 9], ...
                                [27 10 26 9 25 8 5 24 21 7 4 23 20 6 3 22]+40, ...
                                [16 32 13 15 29 31 12 14 28 30 11]+40}; %nanoz correct
                        otherwise
                            error('Animal-Invalid implantStyle: %s', obj.implantStyle);
                    end %switch
                otherwise
                    error('Animal-Invalid probeType: %s', obj.probeType);
            end %switch
            obj.nShanks = numel(obj.cvShankChan);    
            obj = obj.updateDataset();
%             obj.cmFet = cell(numel(obj.cvShankChan), numel(obj.cs_fname));
%             obj.cmWavRef = cell(numel(obj.cvShankChan), numel(obj.cs_fname));
%             if isfield(P, 'readDuration')
%                 obj = obj.getSpikes(P); 
%             end

        end %constructor
    
        
        function obj = updateDataset(obj)
            DATASET;
            eval(sprintf('obj.cs_fname = dataset.%s(:,1);', obj.animalID));
            eval(sprintf('obj.csXTickLabel = dataset.%s(:,2);', obj.animalID));
            eval(sprintf('obj.vnChanOffset = cell2mat(dataset.%s(:,3));', obj.animalID));   
            
            if ~isprop(obj, 'cmFet')
                obj.cmFet = cell(numel(obj.cvShankChan), numel(obj.cs_fname));                
                obj.cmWavRef = cell(numel(obj.cvShankChan), numel(obj.cs_fname));
            else
                cmFet = obj.cmFet;
                cmWavRef = obj.cmWavRef;
                obj.cmFet = cell(numel(obj.cvShankChan), numel(obj.cs_fname));
                obj.cmWavRef = cell(numel(obj.cvShankChan), numel(obj.cs_fname));
                for iFet = 1:numel(cmFet)
                    obj.cmFet{iFet} = cmFet{iFet};
                    obj.cmWavRef{iFet} = cmWavRef{iFet};
                end                  
            end
        end
        
        
        function [obj, cvImp, csDates] = getImpedance(obj, fPlot)
            fPlotMed= 1;
            if nargin < 2
                if nargout == 0, fPlot = 1; else fPlot = 0; end
            end
            mrImp = obj.impedance.mrImp;
            cvImp = cell(obj.nShanks,1);
            csDates = obj.impedance.csDates;
            for iShank=1:obj.nShanks
                cvImp{iShank} = mrImp(obj.cvShankImp{iShank}, :);
            end
            try
            if fPlot
                nDates = numel(csDates);

                if fPlotMed
                    mrMed = zeros(nDates, obj.nShanks);
                    mrHigh = zeros(nDates, obj.nShanks);
                    mrLow = zeros(nDates, obj.nShanks);
                    for iShank=1:obj.nShanks
                        mrMed(:,iShank) = nanmedian(cvImp{iShank});
                        mrLow(:,iShank) = quantile(cvImp{iShank}, 1/4);
                        mrHigh(:,iShank) = quantile(cvImp{iShank}, 3/4);
                    end
                    plotBar(mrMed, mrLow, mrHigh);
                    ylabel('Impedance (MOhm, med+/-iqr)');
                else
                    mrImp90 = zeros(nDates, obj.nShanks); 
                    for iShank=1:obj.nShanks
                        mrImp90(:,iShank) = quantile(cvImp{iShank}, .1);
                    end
                    bar(mrImp90, 1, 'EdgeColor', 'none');
                    ylabel('Impedance (MOhm, 10th pctl)');
                end
                %   bar_input=rand(4,6)/2+0.5;

                vnDates = round(datenum(csDates) - datenum(obj.dateImplanted));
                set(gca, 'XTickLabel', vnDates);
                set(gca, 'box', 'off');
                xlabel('Days after implantation');
                axis([.5 nDates+.5 0 2.5]);
                title(sprintf('%s, %s, %s', obj.animalID, obj.probeType, obj.implantStyle));
                legend({'Shank1', 'Shank2', 'Shank3', 'Shank4'}, 'box', 'off');
            end
            catch err,  disp(lasterr); end
        end
        
        
        %bar plots, cell matrix, shanks x days
        %plotMode: 'ampl', 'counts', 'none'
        function obj = getSpikes(obj, varargin)
            if isstruct(varargin{1}), P = varargin{1};
            else P = struct(varargin{:}); end
            if ~isfield(P, 'readDuration'), P.readDuration = obj.readDuration; end
            if ~isfield(P, 'plotMode'), P.plotMode = 'none'; end
            if ~isfield(P, 'viDay'), P.viDay = 1:numel(obj.cs_fname); end
            
            if P.readDuration ~= obj.readDuration, obj.readDuration = []; end            
            nDays = numel(P.viDay);
            if isempty(obj.readDuration)
                obj.readDuration = P.readDuration;
                obj.ccSpkVpp = cell(obj.nShanks, nDays); %contains cell of vector
                obj.ccSpkTime = cell(obj.nShanks, nDays); %contains cell of vector
                obj.cvSpkThresh = cell(obj.nShanks, nDays);
                for iDay1 = 1:nDays
                    iDay = P.viDay(iDay1);
                    try
                        tic;
                        % Load file
                        vcFname = obj.cs_fname{iDay};
                        [vcFilePath, vcFileName, vcFileExt] = fileparts(vcFname);
                        switch lower(vcFileExt)
                            case '.bin'
                                [mrData, Sfile] = importWhisper(vcFname, 'readDuration', obj.readDuration);
                            case '.ncs' %already channels in Whisper order
                                viChanRead = translateChanTo('Nlx', 1:obj.nChans, 'Whisper1');
                                [mrData, Sfile] = importNlxCsc(vcFname, obj.readDuration, viChanRead);
                            otherwise
                                error('invalid extension: %s', vcFileExt);
                        end
                        fprintf('Loaded %s\n', vcFname); 

                        % Process file
                        [vrFiltB, vrFiltA] = butter(4, obj.freqLim / Sfile.sRateHz * 2,'bandpass');
                        mrData = filter(vrFiltB, vrFiltA, mrData); %filter data
                        for iShank=1:obj.nShanks
                            viChan = obj.cvShankChan{iShank} + obj.vnChanOffset(iDay);
                            [cmSpkWav, cvSpkIdx, vrThresh] = detectSpikes(mrData(:, viChan));
                            obj.ccSpkVpp{iShank, iDay1} = cellfun(@vpp, cmSpkWav, 'UniformOutput', 0);
                            obj.ccSpkTime{iShank, iDay1} = cellfun(@(x)x/Sfile.sRateHz, cvSpkIdx, 'UniformOutput', 0);
                            obj.cvSpkThresh{iShank, iDay1} = vrThresh;
                        end %shank
                        toc;
                    catch err,  disp(lasterr); end
                end %day                
                % cache the info
            end
            if strcmpi(P.plotMode, 'none'), return; end
            
            % compute for plotting
            mrSpkAmp90 = nan(obj.nShanks, nDays); %90th percentile amplitude
            mrSpkAmp90_low = nan(obj.nShanks, nDays);
            mrSpkAmp90_high = nan(obj.nShanks, nDays);
            mnSpkCnt = zeros(obj.nShanks, nDays);
            for iDay = 1:nDays
                for iShank=1:obj.nShanks
                    vrSpkVpp = cell2mat(obj.ccSpkVpp{iShank, iDay});
                    if ~isempty(vrSpkVpp)
                        mrSpkAmp90(iShank, iDay) = quantile(vrSpkVpp, .9);
%                         ci = bootci(100, {@(y)quantile(y, .9), vrSpkVpp});
%                         mrSpkAmp90_low(iShank, iDay) = ci(1);
%                         mrSpkAmp90_high(iShank, iDay) = ci(2);
                        mnSpkCnt(iShank, iDay) = numel(vrSpkVpp);
                    end
                end %shank
            end %day
            obj.mrSpkAmp90 = mrSpkAmp90;
            obj.mnSpkCnt = mnSpkCnt;

            switch lower(P.plotMode)
                case 'ampl'
                vhBars = bar(formatBar(mrSpkAmp90'), 1, 'EdgeColor', 'none'); hold on;
%                 plotBar(mrSpkAmp90', mrSpkAmp90_low', mrSpkAmp90_high');
                ylabel('Spike Ampl (uV, 90th pctl)');
                set(gca, 'XTick', 1:numel(obj.cs_fname));
                set(gca, 'XTickLabel', obj.csXTickLabel);
                set(gca, 'YLim', [0 500]);
                
                case 'counts'
                vhBars = bar(mnSpkCnt'/obj.readDuration, 1, 'EdgeColor', 'none'); hold on;
%                 plotBar(mrSpkAmp90', mrSpkAmp90_low', mrSpkAmp90_high');
                ylabel('Spike counts/s');  
                set(gca, 'YLim', [1 1000]);
%                 set(gca, 'YScale', 'log');
            end
            
            set(gca, 'box', 'off');
            xlabel('Days after implantation');
            set(gca, 'XTick', 1:nDays);
            set(gca, 'XTickLabel', obj.csXTickLabel);
            set(gca, 'XLim', [.5 nDays+.5]);
            title(sprintf('%s, %s, %s', obj.animalID, obj.probeType, obj.implantStyle));
            legend({'Shank1', 'Shank2', 'Shank3', 'Shank4'}, 'box', 'off');
        end %getSpikes        
    
        
        function obj = testObj(obj)
            obj.testField = rand();
        end
        
        
        function mrThresh = plotThresh(obj, varargin)
            P = struct(varargin{:});
            if ~isfield(P,'iShank'), P.iShank = []; end
            if ~isfield(P,'clim'), P.clim = [0 100]; end
            
            if ~isempty(P.iShank)
                viShank = P.iShank;
            else
                viShank = 1:obj.nShanks;
            end
            figure;
            for iShank1 = 1:numel(viShank)
                subplot(numel(viShank),1,iShank1);
                iShank = viShank(iShank1);
                nDays = size(obj.cmFet,2);
                nChans = numel(obj.cvShankChan{iShank});
                mrThresh = zeros(nDays, nChans);
                for iDay=1:nDays
                    mrThresh(iDay,:) = obj.cmFet{iShank,iDay}.vrThresh;
                end
                colormap jet;
                imagesc(mrThresh', 'xdata', 1:nDays, 'ydata', 1:nChans);
                if ~isempty(P.clim), caxis(P.clim); end
                set(gca, 'XTick', 1:2:nDays);
                if iShank1 < numel(viShank)
                    set(gca, 'XTickLabel', []);
                else
                    xlabel('Days'); 
                end
                ylabel('Chan#');
                vcTitle = sprintf('%s-Shank%d', obj.animalID, iShank);
                title(vcTitle);            
            end
        end
        
        
        function plotAmpDist(obj, iDay, iShank)
            if nargin < 2, iDay = []; end
            if nargin < 3, iShank = []; end
            if ~isempty(iDay)
                vrA = obj.cmFet{iShank,iDay}.vrEvtAmp;
                
                figure;
                ksdensity(vrA, 0:1:400, 'bandwidth', 4, 'function', 'survivor');
                vcTitle = sprintf('%s-Shank%d-Day%s-Session#%d', obj.animalID, iShank, obj.csXTickLabel{iDay}, iDay);
                disp(vcTitle);
                title(vcTitle);
                xlabel('Amplitude (uVpp)');
                ylabel('Density');
            else
                figure; hold on;
                nDays = size(obj.cmFet,2);
                mrColor = jet(nDays);
                if isempty(iShank)
                    viShank=1:obj.nShanks;
                else
                    viShank = iShank;
                end
                for iShank = viShank
                    subplot(1,numel(viShank),iShank);
                    hold on;
                    for iDay=1:nDays
                        S = obj.cmFet{iShank,iDay};
                        if isempty(S), continue; end
                        vrA = S.vrEvtAmp;
                        ksdensity(vrA, 0:1:400, 'bandwidth', 4, 'function', 'survivor');
                        vh = get(gca, 'children');
                        set(vh(1), 'color', mrColor(iDay,:));
                    end
                    ylabel('Survivor function');
                    xlabel('Amplitude (vVpp)')
                    title(sprintf('%s-Shank%d', obj.animalID, iShank));
                end
            end
        end
        
        
        function plotRate(obj, iDay, iShank)
            vrT = obj.cmFet{iShank,iDay}.vrTime;
            disp(numel(vrT)/max(vrT))
            binpersec = 100; %nbins per sec
            vl(ceil(vrT*binpersec))=1;
            tAccum = 10;
            n = numel(vl);
%             filtWin = gausswin(100);
%             filtWin=filtWin/sum(filtWin);
%           filtWin = [1:binpersec, (binpersec-1):-1:1];
            filtWin = ones(1,binpersec*tAccum*2);
            figure;plot((1:n)/binpersec, filter(filtWin, tAccum, vl));
            title(sprintf('%s-Shank%d-Day%s', obj.animalID, iShank, obj.csXTickLabel{iDay}));
            xlabel('Time (s)');
            ylabel('Rate (Hz)');
        end
        
        function plotRaster(obj, iDay, iShank)
            if nargin == 1, error('obj.plotRaster(iDay, iShank)'); end
            figure;
            hold on; 
            Sfet = obj.cmFet{iShank, iDay};
            vrT = Sfet.vrTime;
            mlY = Sfet.mlTran;
            iStart = 1;
            nSpk = sum(sum(Sfet.mlTran));
            vrY = zeros(1,nSpk);
            vrX = zeros(1,nSpk);
            nChans = size(mlY,1);
            for iSpk = 1:size(mlY,2)
                vr = find(mlY(:,iSpk));
                iEnd = iStart + numel(vr) - 1;
                vrY(iStart:iEnd) = vr;
                vrX(iStart:iEnd) = vrT(iSpk);
                iStart = iEnd+1;
            end
            
            colormap hot;
            caxis([0 300]);
            patch(repmat(vrX, [2 1]), bsxfun(@plus, vrY, [-.5; .5]), ...
                repmat(vrX, [2 1]), 'EdgeColor', 'flat', 'LineWidth', .1);
            set(gca, 'Color', 'k');
            axis([obj.readDuration(1) obj.readDuration(2), .5 nChans+.5]);
            title(sprintf('%s-Shank%d-Day%d', obj.animalID, iShank, iDay));
        end
        
        
        function [obj, P] = setFields(obj, varargin)
            P = funcInStr(varargin{:});
            csFields = fieldnames(P);
            for iField=1:numel(csFields)
                try
                    eval(sprintf('obj.%s = P.%s;', ...
                        csFields{iField}, csFields{iField}));
                catch err
%                     disp('setFields, P->obj');
%                     disp(csFields{iField});
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
        
        
        %just get features without plotting
        function obj = getFet(obj, varargin)
            obj = obj.updateDataset();
            P = funcInStr(varargin{:});
            if ~isfield(P, 'fPlot'), P.fPlot = 0; end
            if ~isfield(P, 'fOverwrite'), P.fOverwrite = 0; end
            if ~isfield(P, 'viDay')
                P.viDay = 1:numel(obj.cs_fname); 
            elseif isempty(P.viDay)
                P.viDay = 1:numel(obj.cs_fname); 
            end
            if ~isfield(P, 'viShank')
                P.viShank = 1:obj.nShanks;
            elseif isempty(P.viShank)
                P.viShank = 1:obj.nShanks;
            end
            if ~isfield(P, 'readDuration')
                P.readDuration = obj.readDuration;
            end
            if isempty(P.readDuration)
                error('specify readDuration');
            end
            if numel(obj.readDuration) == 1
                P.readDuration = [0, P.readDuration(1)];    
            end
            if isempty(P.readDuration)
                P.viShank = 1:obj.nShanks;
            end
            [obj, P] = obj.setFields(P);     
            
            cs_fname1 = obj.cs_fname(P.viDay);
            warning off;            
            for iDay1 = 1:numel(P.viDay) %limited by memory
                iDay = P.viDay(iDay1);
                vcFname = cs_fname1{iDay1};
                if ~isempty(obj.cmFet{P.viShank(1), iDay})
                    if ~P.fOverwrite
                        fprintf('Already processed day%d, %s\n', iDay, vcFname);
                        continue;                     
                    end
                end
                fprintf('Processing day%d, %s\n', iDay, vcFname);

                P.vcDate = getDateFromFullpath(vcFname);
                [~,~,ext] = fileparts(vcFname);
                switch lower(ext)
                    case '.bin'
                        fcnFileImport = @importWhisper;
                        P.viChan = obj.cvShankChan(P.viShank);
                        P.chOffset = obj.vnChanOffset(iDay);
                    case '.ncs'
                        fcnFileImport = @importNlxCsc;
                        P.viChan = Animal.cvShankChanNlx(P.viShank);
                        P.chOffset = 0;
                end
                try
                    [cmData, Sfile] = fcnFileImport(vcFname, P);
                    obj.cmWavRef(obj.viShank, iDay) = Sfile.cmWavRef;
                    P.cmWavRef = Sfile.cmWavRef;
                    P.sRateHz = Sfile.sRateHz;
                    P.tLoaded = Sfile.tLoaded;
                    cvFet = cell(size(P.viShank));
                    if P.fParfor
                        P.fPlot = 0;
                        parfor iShank1 = 1:numel(P.viShank)
                            cvFet{iShank1} = buildSpikeTable(cmData{iShank1}, P);                            
%                             cvFet{iShank1} = detectPeaks(cmData{iShank1}, P, iShank1);
                            cvFet{iShank1} = cluster1(cvFet{iShank1}, iDay, P.viShank(iShank1), P);
                        end      
                    else
%                         if P.fPlot, figure; end
                        for iShank1 = 1:numel(P.viShank)     
                            cvFet{iShank1} = buildSpikeTable(cmData{iShank1}, P);                            
%                             cvFet{iShank1} = detectPeaks(cmData{iShank1}, P, iShank1);
                            cvFet{iShank1} = cluster1(cvFet{iShank1}, iDay, P.viShank(iShank1), P);
                        end       
                    end
                catch err
                    fprintf('Error iDay:%d, %s\n', iDay, vcFname);
                    disp(lasterr);                    
                end
                cmData = []; %free memory
                obj.cmFet(P.viShank, P.viDay(iDay1)) = cvFet;
            end   
            
            if P.fPlot
                if P.fCluster
                    obj.plotClusters(); 
                elseif P.fMeasureEvent
                    obj.plotEvents();
                end
            end         
        end %getfet
        
        
        % use plotCluster for plotting
        function obj = cluster(obj, varargin)
            [obj, P] = obj.setFields(varargin{:});
            if ~isfield(P, 'fPlot'), P.fPlot = 0; end
            
            cvFet = obj.cmFet(obj.viShank, obj.viDay);
            [viDay, viShank] = meshgrid(obj.viDay, obj.viShank);
            warning off;
            if obj.fParfor
                parfor iFet = 1:numel(cvFet) %PCA only
                    cvFet{iFet} = ...
                        cluster1(cvFet{iFet}, viDay(iFet), viShank(iFet), P);
                end
            else
                for iFet = 1:numel(cvFet)
                    cvFet{iFet} = ...
                        cluster1(cvFet{iFet}, viDay(iFet), viShank(iFet), P);
                end
            end
            obj.cmFet(obj.viShank, obj.viDay) = cvFet;          
            
            if P.fPlot, obj.plotClusters(); end
        end
         
        
        function plotBarClu(obj, varargin)
            P = funcInStr(varargin{:});
            if ~isfield(P, 'viShank'), P.viShank = 1:obj.nShanks; end
            if ~isfield(P, 'viDay'), P.viDay = 1:numel(obj.cs_fname); end
            
            P.cs_fname = obj.cs_fname;
            P.animalID = obj.animalID;
            cvFet = obj.cmFet(P.viShank, P.viDay);
            [viDay, viShank] = meshgrid(P.viDay, P.viShank);
            
            mrBar = zeros(size(obj.cmFet));
            for iFet = 1:numel(cvFet)
                S = cvFet{iFet};
                if isempty(S), continue; end
                if ~isfield(S, 'Sclu'), continue; end
                if isempty(S.Sclu), continue; end %no clu detected             
                iShank = viShank(iFet);
                iDay = viDay(iFet);
                viClu = S.Sclu.cl;
                mrBar(iShank, iDay) = max(viClu)-1;
                fprintf('%s, day%d, shank%d, #Clu=%d, %d/%d spikes(%0.1f%%), <isoDist>=%0.1f, <isi rat>=%0.3f\n', ...
                    obj.animalID, iDay, iShank, max(S.Sclu.cl)-1, sum(S.Sclu.cl>1), numel(S.Sclu.cl), ...
                    sum(S.Sclu.cl>1) / numel(S.Sclu.cl) * 100, ...
                    nanmean(S.Sclu.vrIsoDist(2:end)), nanmean(S.Sclu.vrIsiRatio(2:end)));
                disp('Iso Dist:');
                disp(S.Sclu.vrIsoDist(:)');
                disp('ISI Ratio:');
                disp(S.Sclu.vrIsiRatio(:)');
            end
            figure; bar(mrBar', 1, 'stacked');
            xlabel('Day #');
            set(gca, 'XTick', 1:numel(obj.cs_fname));
            set(gca, 'XTickLabel', obj.csXTickLabel);
            ylabel('# Clusters');
            title(sprintf(...
                '%s; %d-%d s; %d-%d Hz', ...
                obj.animalID, obj.readDuration(1), obj.readDuration(2), ...
                obj.freqLim(1), obj.freqLim(2)));                        
        end
        
                
        function plotClusters(obj, varargin)
            [obj, P] = obj.setFields(varargin{:});
            if ~isfield(P, 'fPlot'), P.fPlot = 1; end
            
            cvFet = obj.cmFet(obj.viShank, obj.viDay);
            [viDay, viShank] = meshgrid(obj.viDay, obj.viShank);
            
            for iFet = 1:numel(cvFet)
                S = cvFet{iFet};
                if isempty(S), continue; end
                if isempty(S.Sclu), continue; end %no clu detected
                
                iShank = viShank(iFet);
                iDay = viDay(iFet);

                vcDate = getDateFromFullpath(obj.cs_fname{iDay});
                P.vcTitle = sprintf('%s, %s, Shank%d', obj.animalID, vcDate, iShank);
                P.viClu = S.Sclu.cl;
%                 fprintf('%s, day%d, shank%d, #Clu=%d, %d/%d spikes(%0.1f%%), <isoDist>=%0.1f, <isi rat>=%0.3f\n', ...
%                     obj.animalID, iDay, iShank, max(S.Sclu.cl)-1, ...
%                     sum(S.Sclu.cl>1), numel(S.Sclu.cl), ...
%                     sum(S.Sclu.cl>1) / numel(S.Sclu.cl) * 100, ...
%                     nanmean(S.Sclu.vrIsoDist(2:end)), ...
%                     nanmean(S.Sclu.vrIsiRatio(2:end)));

                if P.fPlot
                    fig = figure('Visible', 'off', 'Position', ...
                        round(get(0, 'ScreenSize')*.8));     
                    if obj.fShowWaveform
                        subplot(3,2,1);
                        plotScienceClu(S.Sclu);

                        subplot(3,2,[3,5]); 
                        figure(fig);
                        plotTetClu(S.mrFet, P);
                        
                        subplot(3,2,2);
                        plotCluRaster(S.vrTime, S.Sclu.cl);

                        subplot(3,2,[4,6]); 
                        figure(fig);                    
                        plotWaveform(S, P);
                    else
                        subplot(2,2,1);
                        plotScienceClu(S.Sclu);

                        subplot(2,2,2); 
                        figure(fig);
                        plotTetClu(S.mrFet, P);
                        
                        subplot(2,2,3:4);
                        plotCluRaster(S.vrTime, S.Sclu.cl);
                    end
                    
                    set(fig, 'Name', sprintf(...
                        'day%d-shank%d; %d-%d sec; 0..%d u%s; %d-%d Hz, fUseSubThresh=%d, fMeanSubt=%d, nInterp=%d, vcDist=%s, fDiffPair=%d', ...
                        iDay, iShank, obj.readDuration(1), obj.readDuration(2), obj.maxAmp, ...
                        obj.vcPeak, obj.freqLim(1), obj.freqLim(2), ...
                        obj.fUseSubThresh, obj.fMeanSubt, obj.nInterp, ...
                        obj.vcDist, obj.fDiffPair));
                    set(fig, 'Visible', 'on');
                end %fPlot
                drawnow;
%                 set(fig, 'Visible', 'on');
%                 drawnow;
            end
        end
        
        
        % to be deprecated
        function [cS, vcTitle] = plotClusters1(obj, varargin)
            P = funcInStr(varargin{:});
            if ~isfield(P, 'viDay'), P.viDay = 1:numel(obj.cs_fname); end
            if ~isfield(P, 'readDuration'), P.readDuration = [0, 100]; end
            if ~isfield(P, 'freqLim'), P.freqLim = [300 3000]; end
            if ~isfield(P, 'maxAmp'), P.maxAmp = 800; end
            if ~isfield(P, 'fUseSubThresh'), P.fUseSubThresh = 0; end
            if ~isfield(P, 'thresh'), P.thresh = ''; end
            if ~isfield(P, 'fMeanSubt'), P.fMeanSubt = 1; end
            if ~isfield(P, 'viShank'), P.viShank = 1:numel(obj.cvShankChan); end
            if ~isfield(P, 'vcPeak'), P.vcPeak = 'Vpp'; end  %or 'Vm'
%             if ~isfield(P, 'fSpkWav'), P.fSpkWav = 0; end  %or 'Vm'
            if ~isfield(P, 'fPlot'), P.fPlot = 1; end  %or 'Vm'
            if ~isfield(P, 'spkLim'), P.spkLim = [-8, 16]; end 
            
            nDays1 = numel(P.viDay);
            
            cS = cell(size(P.viDay));
            for iDay1 = 1:numel(P.viDay)
                vcFullpath = obj.cs_fname{P.viDay(iDay1)};
                [~,vcFilename,~] = fileparts(vcFullpath);
                [cmData, Sfile] = importWhisper(vcFullpath, 'readDuration', P.readDuration, ...
                    'viChan', {obj.cvShankChan}, 'freqLim', P.freqLim, 'fMeanSubt', P.fMeanSubt);
                
                if P.fPlot, subplot(1, nDays1, iDay1); end %, 'Position', [(iDay1-1)/nDays1, .05, 1/nDays1*.95, .95]);
                cS{iDay1} = detectPeaks(cmData(P.viShank), 'maxAmp', P.maxAmp, 'fPlot', P.fPlot, ...
                        'fUseSubThresh', P.fUseSubThresh, 'vcPeak', P.vcPeak, ...
                        'sRateHz', Sfile.sRateHz, 'thresh', P.thresh, ...
                        'vcDate', vcFilename(1:13), 'fSpkWav', P.fSpkWav, ...
                        'spkLim', P.spkLim);
                if P.fPlot, title(sprintf('%s', vcFilename(1:13)), 'interpreter', 'none'); end
%                 title(sprintf('%s, t(s):%d-%d, %s', vcFilename, P.readDuration(1), P.readDuration(2), get(gcf, 'Name')));
            end
            vcTitle = sprintf(...
                '%s; %d-%ds; 0..%d u%s; %d-%d Hz; #thresh:%d; fUseSubThresh:%d; fMeanSubt:%d, nInterp;%d', ...
                obj.animalID, P.readDuration(1), P.readDuration(2), P.maxAmp, ...
                P.vcPeak, P.freqLim(1), P.freqLim(2), numel(P.thresh), ...
                P.fUseSubThresh, P.fMeanSubt, P.nInterp);
%             if P.fPlot
%                 warning off;
%                 set(gcf, 'Name', vcTitle);
%                 try  tightfig; 
%                     catch err, disp(lasterr); end
%             end
        end
        
        
        function plotEvents(obj, varargin)            
            P = funcInStr(varargin{:});
            if ~isfield(P, 'viShank'), P.viShank = 1:obj.nShanks; end
            if ~isfield(P, 'viDay'), P.viDay = 1:numel(obj.cs_fname); end
            cvFet = obj.cmFet(P.viShank, P.viDay);
            [viDay, viShank] = meshgrid(P.viDay, P.viShank);   
            P.fDiffPair = obj.fDiffPair;
            
            csMeas = {'Amp90', 'Amp50', 'Rate', 'Rate90', ...
                'N1', 'N2', 'N3', 'N4+'};
            trFetEvt = zeros(size(obj.cmFet,1), size(obj.cmFet,2), numel(csMeas));
            
            for iFet = 1:numel(cvFet)
                S = cvFet{iFet};
                if isempty(S), continue; end
                iShank = viShank(iFet);
                iDay = viDay(iFet);                
                trFetEvt(iShank, iDay,:) = measureEvents(S, P);
            end
            
            vrX = 1:numel(obj.cs_fname);
            figure;
            AX = [];
            for iShank1 = 1:numel(P.viShank) 
%                 figure;
                iShank = P.viShank(iShank1);
                mrFetEvt = reshape(trFetEvt(iShank, :,:), ...
                    [size(trFetEvt,2), numel(csMeas)]);
                iPlot = iShank1;
                AX(end+1) = subplot(3,numel(P.viShank),iPlot); hold on;
                plot(vrX, mrFetEvt(:,1), 'b.-');
                plot(vrX, mrFetEvt(:,2), 'b.:');
                if iShank1==1, ylabel('Spk Ampl (uV)'); end
                if iShank1>1, set(gca, 'YTickLabel', []); end
                set(gca, {'XTick', 'XTickLabel'}, ...
                    {1:numel(obj.cs_fname), ''});
                title(sprintf('Shank %d', iShank));
                xlim([0, numel(obj.cs_fname)+1]);  
%                 title(sprintf(...
%                     '%s-Shank%d; %d-%d s', ...
%                     obj.animalID, iShank, obj.readDuration(1), obj.readDuration(2)));   

                iPlot = iShank1 + numel(P.viShank);
                AX(end+1) = subplot(3,numel(P.viShank),iPlot); hold on;
                plot(vrX, mrFetEvt(:,3), 'r.-');
                plot(vrX, mrFetEvt(:,4), 'r.:');
                if iShank1==1, ylabel('Spk Rate (Hz)'); end
                if iShank1>1, set(gca, 'YTickLabel', []); end
                set(gca, {'XTick', 'XTickLabel'}, ...
                    {1:numel(obj.cs_fname), ''});
                xlim([0, numel(obj.cs_fname)+1]);
                
                iPlot = iShank1 + 2*numel(P.viShank);
                AX(end+1) = subplot(3,numel(P.viShank),iPlot); hold on;
                colormap jet;
                bar(vrX, mrFetEvt(:,5:end), 'stacked', 'EdgeColor', 'none');
%                 legend({'1','2','3','4','5','6','7','8+'});
                xlim([0, numel(obj.cs_fname)+1]);
                if iShank1==1, ylabel('# events/s'); end
                if iShank1>1, set(gca, 'YTickLabel', []); end
                xlabel('Day');
                set(gca, {'XTick', 'XTickLabel'}, ...
                    {1:numel(obj.cs_fname), obj.csXTickLabel});         
            end
            linkaxes(AX(1:3:end), 'xy');    
            linkaxes(AX(2:3:end), 'xy');    
            linkaxes(AX(3:3:end), 'xy');    
            
            vcTitle=(sprintf(...
                '%s; %d-%ds; %d-%d Hz; #thresh:%d; fUseSubThresh:%d; fMeanSubt:%d, nInterp:%d, fDiffPair:%d', ...
                obj.animalID, obj.readDuration(1), obj.readDuration(2), ...
                obj.freqLim(1), obj.freqLim(2), numel(obj.thresh), ...
                obj.fUseSubThresh, obj.fMeanSubt, obj.nInterp, obj.fDiffPair));
            set(gcf,'Name',vcTitle);
        end
        
        
        % converts class to struct and save
        function save(obj, fName)
            if nargin < 2, fName = obj.animalID; end
            csFields = fieldnames(obj);
            S = [];
            for iField=1:numel(csFields)
                vcField = csFields{iField};
                eval(sprintf('S.%s = obj.%s;', vcField, vcField));
            end
            save(fName, 'S', '-v7.3');
        end
    end %methods    
end