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
        filterFreq = [300 3000];
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
        viShank; viDay;
        freqLim; spkLim; 
        vcPeak; %feature to detect
        vcFet; vcDist; maxAmp; nInterp; thresh;
        nPadding; %number of samples to pad around spkLim
        fMeanSubt; fUseSubThresh; fCov; fSpkWav; fPlot; fParfor; fPeak; 
        
        % cluster
        fCleanClu; fAskUser; fShowWaveform; 
        SIGMA_FACTOR; fHalo; fNormFet; nclu; % clusterScience settings
        spkRemoveZscore; % remove waveform 
    end
    
    methods
        function obj = Animal(animalID, varargin)
            if nargin == 0                
                error('Choose animals: %s', cell2mat(Animal.csAnimals));
            end
            P = struct(varargin{:});
            obj.animalID = animalID;
            obj.impedance = Impedance(animalID);
            
            switch obj.animalID
                case 'ANM282996'
                    obj.dateImplanted = '1/6/2015';
                    obj.implantStyle = 'RICHP';
                    obj.probeType = 'IMECI';
                    obj.cs_fname = { ...
                        'D:\Chronic\ANM282996\2015-01-07_14-13-22\CSC1.ncs', ...
                        'D:\Chronic\ANM282996\2015-01-09_11-44-53\CSC1.ncs', ...
                        'D:\Chronic\ANM282996\20150114_1150.bin', ...
                        'D:\Chronic\ANM282996\20150116_1845.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150119_1800.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150121_1730.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150123_1647.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150126-1133.bin', ...
                        'D:\Chronic\ANM282996\20150203-2313_6-2HS_DispOff_AuxOff_Sbox1.bin', ...
                        'D:\Chronic\ANM282996\20150210-1645.bin', ...
                        'D:\Chronic\ANM282996\2015-02-10_18-43-42\CSC1.ncs', ...
                        'D:\Chronic\ANM282996_ANM286577\20150210-1742.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150213-1350.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150213-1450_192ch.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150217-1616.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150220-1120_test.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150223-1500.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150226-1549.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150302-1537.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150306-1345.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150309-1410.bin'};
                    obj.csXTickLabel =  {'1', '3', '8', '10', '13', '15', '17', '20'...
                        '28', '35', '35N', '35D', '38D', '38T', '42', '45', ...
                        '48', '51', '55', '59', '62'};

                case 'ANM279097' %correct pedot orientation
                    obj.dateImplanted = '1/12/2015';
                    obj.implantStyle = 'HOLTZMANT';
                    obj.probeType = 'PEDOT';
                    obj.cs_fname = {'D:\Chronic\ANM279097\20150114_1950.bin', ...
                        'D:\Chronic\ANM279097_ANM279094\20150117_1620.bin', ...
                        'D:\Chronic\ANM279097_ANM279094\20150119_2018.bin', ...
                        'D:\Chronic\ANM279097_ANM279094\20150120-1650.bin'};
                    obj.csXTickLabel = {'1', '7', '8', '10'};

                case 'ANM279094' %correct pedot orientation (1/13)
                    obj.dateImplanted = '1/13/2015';
                    obj.implantStyle = 'HOLTZMANT';
                    obj.probeType = 'PEDOT';
                    obj.cs_fname = {'D:\Chronic\ANM279094\20150114_1800.bin', ...
                        'D:\Chronic\ANM279097_ANM279094\20150117_1620.bin', ...
                        'D:\Chronic\ANM279097_ANM279094\20150119_2018.bin', ...
                        'D:\Chronic\ANM279097_ANM279094\20150120-1650.bin', ...
                        'D:\Chronic\ANM279094\20150124-1450.bin'};
                    obj.csXTickLabel = {'1', '4', '6', '7', '11'};
                    obj.vnChanOffset = [0 64 64 64 0];

                case 'ANM286577' %flip TiN alive (1/15)
                    obj.dateImplanted = '1/15/2015';
                    obj.implantStyle = 'HOLTZMANT';
                    obj.probeType = 'IMECI';
                    obj.cs_fname = { ...
                        'D:\Chronic\ANM286577\20150116_1750.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150119_1800.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150121_1730.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150123_1647.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150126-1133.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150210-1742.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150213-1350.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150213-1450_192ch.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150217-1616.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150220-1120_test.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150223-1500.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150226-1549.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150302-1537.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150306-1345.bin', ...
                        'D:\Chronic\ANM282996_ANM286577\20150309-1410.bin'};
                    obj.csXTickLabel = {...
                        '1', '4', '6', '8', '11', '26', '29D', '29T', ...
                        '33', '36', '39', '42', '46', '50', '53'};
                    obj.vnChanOffset = [...
                         0 64 64 64 64 64 64 64, ...
                        64 64 64 64 64 64 64];

                case 'ANM286578' %flip TiN (1/20)
                    obj.dateImplanted = '1/20/2015';
                    obj.implantStyle = 'HOLTZMANT';
                    obj.probeType = 'IMECI';
                    obj.cs_fname = { ...
                        'D:\Chronic\ANM286578\20150121-0453.bin', ...
                        'D:\Chronic\ANM286578\20150121-1622.bin', ...
                        'D:\Chronic\ANM286578\20150123-1523.bin', ...
                        'D:\Chronic\ANM286578\20150125-1625.bin', ...
                        'D:\Chronic\ANM286578\20150203-1730.bin'};
                    obj.csXTickLabel = {'0', '1', '3', '5', '14'};
                    
                case 'ANM287075'
                    obj.dateImplanted = '2/20/2015';
                    obj.implantStyle = 'RICHP';
                    obj.probeType = 'PEDOT';
                    obj.cs_fname = { ...
                        'D:\Chronic\ANM287075\20150220-2155.bin', ...
                        'D:\Chronic\ANM287075\20150222-1730.bin', ...
                        'D:\Chronic\ANM287075\20150224-1615.bin', ...
                        'D:\Chronic\ANM287075\20150224-1723.bin', ...
                        'D:\Chronic\ANM287075\20150226-1755.bin', ...
                        'D:\Chronic\ANM287075_ANM287074\20150302-1706.bin', ...
                        'D:\Chronic\ANM287075_ANM287074\20150304-1215.bin', ...
                        'D:\Chronic\ANM287075_ANM287074\20150306-1345.bin', ...
                        'D:\Chronic\ANM287075_ANM287074\20150309-1550.bin'};
                    obj.csXTickLabel = {'0A', '2A', '4A', '4S', '6', '10', '12', '14', '17'};
                    
                case 'ANM287074'
                    obj.dateImplanted = '2/27/2015';
                    obj.implantStyle = 'RICHP';
                    obj.probeType = 'PEDOT';
                    obj.cs_fname = { ...
                        'D:\Chronic\ANM287074\20150227-2002.bin', ...
                        'D:\Chronic\ANM287075_ANM287074\20150302-1706.bin', ...
                        'D:\Chronic\ANM287075_ANM287074\20150304-1215.bin', ...
                        'D:\Chronic\ANM287075_ANM287074\20150306-1345.bin', ...
                        'D:\Chronic\ANM287075_ANM287074\20150309-1550.bin'};
                    obj.csXTickLabel = {'0', '3', '5', '7', '10'};
                    obj.vnChanOffset = [...
                         0 64 64 64 64];
                     
                case 'ANM292757'
                    obj.dateImplanted = '3/10/2015';
                    obj.implantStyle = 'RICHP';
                    obj.probeType = 'IMECI';
                    obj.cs_fname = { ...
                        'D:\Chronic\ANM292757\20150310-2130.bin'};
                    obj.csXTickLabel = {'0'};
                    obj.vnChanOffset = [0];
                     
                otherwise
                    error('Invalid AnimalID');
            end %switch
            
            if isempty(obj.vnChanOffset)
                obj.vnChanOffset = zeros(size(obj.cs_fname)); 
            end

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
            
            obj.cmFet = cell(numel(obj.cvShankChan), numel(obj.cs_fname));
            obj.nShanks = numel(obj.cvShankChan);    
            if isfield(P, 'readDuration')
                obj = obj.getSpikes(P); 
            end

        end %constructor
    
        
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
                        [vrFiltB, vrFiltA] = butter(4, obj.filterFreq / Sfile.sRateHz * 2,'bandpass');
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
        
        
        function plotRaster(obj, iDay, iShank)
            if nargin == 1, error('obj.plotRaster(iDay, iShank)'); end
            cSpkVpp = obj.ccSpkVpp{iShank, iDay};
            cSpkTime = obj.ccSpkTime{iShank, iDay};
            nChans1 = numel(cSpkVpp);
            
            hold on;            
            vrC = cell2mat(cSpkVpp);
            vrX = cell2mat(cSpkTime);
            vrY = zeros(size(vrX));
            iStart = 1;
            for iChan1 = 1:nChans1
                iEnd = iStart + numel(cSpkVpp{iChan1}) - 1;
                vrY(iStart:iEnd) = iChan1;
                iStart = iEnd+1;
            end
            
            colormap hot;
            caxis([0 300]);
            patch(repmat(vrX, [2 1]), bsxfun(@plus, vrY, [-.5; .5]), ...
                repmat(vrC, [2 1]), 'EdgeColor', 'flat');
            set(gca, 'Color', 'k');
            axis([obj.readDuration(1) obj.readDuration(2), .5 nChans1+.5]);
        end
        
        
        %just get features without plotting
        function obj = getFet(obj, varargin)
            P = funcDefStr(funcInStr(varargin{:}), ...
                'viDay', 1:numel(obj.cs_fname), 'freqLim', [300, 6000], ...
                'readDuration', [0, 100], 'maxAmp', 1000, ...
                'fUseSubThresh', 0, 'thresh', [], ...
                'fMeanSubt', 1, 'viShank', 1:obj.nShanks, ...
                'viShank', 1:obj.nShanks, 'vcPeak', 'Vpp', ...
                'fSpkWav', 0, 'fPlot', 1, 'fPeak', 1, ...
                'fPlot', 1, 'spkLim', [-8 12], 'fParfor', 1, ...
                'nPadding', 4);
            if numel(P.readDuration) == 1
                P.readDuration = [0, P.readDuration(1)];
            end
            csFields = fieldnames(P);
            for iField=1:numel(csFields)
                try
                    eval(sprintf('obj.%s = P.%s;', ...
                        csFields{iField}, csFields{iField}));
                catch err
                    disp(csFields{iField});
                end
            end
            
            cs_fname1 = obj.cs_fname(P.viDay);
            warning off;            
            for iDay1 = 1:numel(P.viDay) %limited by memory
                iDay = P.viDay(iDay1);
                vcFname = cs_fname1{iDay1};
                P.vcDate = getDateFromFullpath(vcFname);
                [~,~,ext] = fileparts(vcFname);
                switch lower(ext)
                    case '.bin'
                        fcnFileImport = @importWhisper;
                        P.viChan = obj.cvShankChan(P.viShank);
                    case '.ncs'
                        fcnFileImport = @importNlxCsc;
                        P.viChan = Animal.cvShankChanNlx(P.viShank);
                end
                try
                    [cmData, Sfile] = fcnFileImport(vcFname, P);
                    P.sRateHz = Sfile.sRateHz;  
                    cvFet = cell(size(P.viShank));
                    if P.fParfor
                        P.fPlot = 0;
                        parfor iShank1 = 1:numel(P.viShank)
                            cvFet{iShank1} = detectPeaks(cmData{iShank1}, P);
                        end      
                    else
                        if P.fPlot, figure; end
                        for iShank1 = 1:numel(P.viShank)       
                            cvFet{iShank1} = detectPeaks(cmData{iShank1}, P);
                        end       
                    end
                catch err
                    fprintf('iDay:%d, %s\n', iDay, vcFname);
                    disp(err);                    
                end
                cmData = []; %free memory
                obj.cmFet(P.viShank, P.viDay(iDay1)) = cvFet;
            end   
        end %getfet
        
        
        % use plotCluster for plotting
        function obj = cluster(obj, varargin)
            P = funcDefStr(funcInStr(varargin{:}), ...
                'vcDist', 'euclidean', 'maxAmp', 1000, ...
                'vcFet', 'peak', 'fNormFet', 0, ...
                'fParfor', 0, 'fPlot', 1, 'viShank', obj.viShank, ...
                'viDay', obj.viDay, ...
                'fAskUser', 0, 'nclu', [], 'fCleanClu', 1, ...
                'spkLim', obj.spkLim, 'cs_fname', obj.cs_fname, ...
                'animalID', obj.animalID, 'nPadding', obj.nPadding, ...
                'spkRemoveZscore', []);
            csFields = fieldnames(P);
            for iField=1:numel(csFields)
                try
                eval(sprintf('obj.%s = P.%s;', ...
                    csFields{iField}, csFields{iField}));
                catch
                    disp(csFields{iField});
                end
            end     
            
            cvFet = obj.cmFet(P.viShank, P.viDay);
            [viDay, viShank] = meshgrid(P.viDay, P.viShank);
            if P.fParfor
                warning off;
                try
                    parfor iFet = 1:numel(cvFet) %PCA only
                        cvFet{iFet} = cluster1(cvFet{iFet}, viDay(iFet), viShank(iFet), P);
                    end
                catch err
                    disp('Parfor failed. Trying for-loop instead');
                    for iFet = 1:numel(cvFet)
                        cvFet{iFet} = cluster1(cvFet{iFet}, viDay(iFet), viShank(iFet), P);
                    end
                end
            else
                for iFet = 1:numel(cvFet)
                    cvFet{iFet} = cluster1(cvFet{iFet}, viDay(iFet), viShank(iFet), P);
                end
            end
            obj.cmFet(P.viShank, P.viDay) = cvFet;          
            
            if P.fPlot, obj.plotClusters(P); end
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
                if isempty(S.Sclu), continue; end %no clu detected             
                iShank = viShank(iFet);
                iDay = viDay(iFet);
                viClu = S.Sclu.cl;
                mrBar(iShank, iDay) = max(viClu)-1;
                
                fprintf('%s, day%d, shank%d, #Clu=%d, %d/%d spikes(%0.1f%%), <isoDist>=%0.1f, <isi rat>=%0.3f\n', ...
                    obj.animalID, iDay, iShank, max(S.Sclu.cl)-1, sum(S.Sclu.cl>1), numel(S.Sclu.cl), ...
                    sum(S.Sclu.cl>1) / numel(S.Sclu.cl) * 100, ...
                    nanmean(S.vrIsoDist(2:end)), nanmean(S.vrIsiRatio(2:end)));
                disp('Iso Dist:');
                disp(S.vrIsoDist(:)');
                disp('ISI Ratio:');
                disp(S.vrIsiRatio(:)');
            end
            figure; bar(mrBar', 1, 'stacked');
            xlabel('Day #');
            ylabel('# Clusters');
            title(sprintf(...
                '%s; %d-%d s; %d-%d Hz', ...
                obj.animalID, obj.readDuration(1), obj.readDuration(2), ...
                obj.freqLim(1), obj.freqLim(2)));                        
        end
        
                
        function plotClusters(obj, varargin)
            P = funcDefStr(funcInStr(varargin{:}), ...
                'maxAmp', 1000, 'fShowWaveform', 1, 'fPlot', 1, ...
                'viShank', 1:obj.nShanks, 'viDay', 1:numel(obj.cs_fname), ...
                'cs_fname', obj.cs_fname, 'animalID', obj.animalID, ...
                'nPadding', obj.nPadding, 'spkLim', obj.spkLim);
            
            cvFet = obj.cmFet(P.viShank, P.viDay);
            [viDay, viShank] = meshgrid(P.viDay, P.viShank);
            
            for iFet = 1:numel(cvFet)
                S = cvFet{iFet};
                if isempty(S), continue; end
                if isempty(S.Sclu), continue; end %no clu detected
                
                iShank = viShank(iFet);
                iDay = viDay(iFet);

                vcDate = getDateFromFullpath(obj.cs_fname{iDay});
                P.vcTitle = sprintf('%s, %s, Shank%d', obj.animalID, vcDate, iShank);
                      
                fprintf('%s, day%d, shank%d, #Clu=%d, %d/%d spikes(%0.1f%%), <isoDist>=%0.1f, <isi rat>=%0.3f\n', ...
                    obj.animalID, iDay, iShank, max(S.Sclu.cl)-1, sum(S.Sclu.cl>1), numel(S.Sclu.cl), ...
                    sum(S.Sclu.cl>1) / numel(S.Sclu.cl) * 100, ...
                    nanmean(S.vrIsoDist(2:end)), nanmean(S.vrIsiRatio(2:end)));

                if P.fPlot
                    fig = figure('Visible', 'off', 'Position', ...
                        round(get(0, 'ScreenSize')*.8));     
                    if P.fShowWaveform
                        subplot(3,2,1);
                        plotScienceClu(S.Sclu);

                        subplot(3,2,3); 
                        figure(fig);
                        plotTetClu(S.mrPeak, 'viClu', S.Sclu.cl, 'maxAmp', ...
                            P.maxAmp, 'vcTitle', P.vcTitle);
                        
                        subplot(3,2,5);
                        plotCluRaster(S.vrTime, S.Sclu.cl);

                        subplot(3,2,[2,4,6]); 
                        figure(fig);                    
                        plotWaveform(S, P);
                    else
                        subplot(2,2,1);
                        plotScienceClu(S.Sclu);

                        subplot(2,2,2); 
                        figure(fig);
                        plotTetClu(S.mrPeak, 'viClu', S.Sclu.cl, 'maxAmp', ...
                            P.maxAmp, 'vcTitle', P.vcTitle);
                        
                        subplot(2,2,3:4);
                        plotCluRaster(S.vrTime, S.Sclu.cl);
                    end
                    
                    set(fig, 'Name', sprintf(...
                        'day%d-shank%d; %d-%d sec; 0..%d u%s; %d-%d Hz, fUseSubThresh=%d, fMeanSubt=%d, nInterp=%d, vcDist=%s', ...
                        iDay, iShank, obj.readDuration(1), obj.readDuration(2), P.maxAmp, ...
                        obj.vcPeak, obj.freqLim(1), obj.freqLim(2), ...
                        obj.fUseSubThresh, obj.fMeanSubt, obj.nInterp, ...
                        obj.vcDist));
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
            if ~isfield(P, 'fSpkWav'), P.fSpkWav = 0; end  %or 'Vm'
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
    end %methods    
end