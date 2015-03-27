% S150210_load neuralynx
function [mrWav, S] = importNlxCsc(vcFullPath, varargin)
% mrData: channel data
% S: file meta
% returns in Whisper channel order
P = funcInStr(varargin{:});
if ~isfield(P, 'readDuration'), P.readDuration = []; end %in sec or range
if ~isfield(P, 'viChan'), P.viChan = []; end
if ~isfield(P, 'fid'), P.fid = []; end
if ~isfield(P, 'freqLim'), P.freqLim = []; end
if ~isfield(P, 'fMeanSubt'), P.fMeanSubt = 0; end
if ~isfield(P, 'nChans'), P.nChans = 64; end

[vcFilePath, vcFileName, vcFileExt] = fileparts(vcFullPath);
% vcFilePath = 'D:\ANM282996\2015-01-07_14-13-22\';
iADBitVolts = 16;
iSR = 14; %sampling rate index

mrWav = [];
for iChan = 1:P.nChans
    vcFullPath = sprintf('%s\\CSC%d.ncs', vcFilePath, iChan);
    try
        [vrWav, Header] = Nlx2MatCSC(vcFullPath, [0 0 0 0 1], 1, 1, [] );
    catch err
        disp(err)
    end
    if isempty(mrWav) %first record
        vcADBitVolts = Header{iADBitVolts};
        ADBitVolts = str2double(vcADBitVolts(strfind(vcADBitVolts, ' ')+1:end));
        vcsRateHz = Header{iSR};
        sRateHz = str2double(vcsRateHz(strfind(vcsRateHz, ' ')+1:end)); 
        scale = -ADBitVolts * 1e6; %NLX saves inverted waveform
        switch numel(P.readDuration)
            case 0
                nSamples = numel(vrWav); 
                viRange = 1:nSamples;
            case 1
                nSamples = round(sRateHz * P.readDuration); 
                viRange = 1:nSamples;
            case 2
                nSamples = round(sRateHz * diff(P.readDuration));
                viRange = round(sRateHz * P.readDuration(1)) + ...
                    (1:nSamples);
        end
        mrWav = zeros([nSamples, P.nChans], 'single');
    end
    if isempty(P.readDuration)
        mrWav(:, iChan) = vrWav;
    else
        mrWav(:, iChan) = vrWav(viRange);
    end
end
if ~isempty(P.freqLim)
    [vrFiltB, vrFiltA] = butter(4, P.freqLim / sRateHz * 2,'bandpass');    
else
    vrFiltA = [];
end
if isempty(P.viChan), P.viChan = 1:size(mrWav,1); end
if ~iscell(P.viChan), P.viChan = {P.viChan}; end

cmWav = cell(size(P.viChan));
for iShank1 = 1:numel(P.viChan)
    mrWav1 = mrWav(:,P.viChan{iShank1});    
    % Mean subtract
    if P.fMeanSubt
        mrWav1 = bsxfun(@minus, mrWav1, mean(mrWav1, 2)); 
    end   
    % Filter or scale
    if ~isempty(vrFiltA)
        mrWav1 = filter(vrFiltB*scale, vrFiltA, mrWav1); %filter data    
    else
    	mrWav1 = mrWav1 * scale;
    end
    cmWav{iShank1} = mrWav1;
end

% output formatting
if ~iscell(P.viChan)
    mrWav = cmWav{1}; 
else 
    mrWav = cmWav;
end

%% package by shanks

S = struct('sRateHz', sRateHz, 'nChans', P.nChans); %outputs in microvolts