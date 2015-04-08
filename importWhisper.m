function [cmWav, S, fid] = importWhisper(vcFullPath, varargin)
% read_duration: time duration to read (sec)
% mrWav: in microvolts
% if viChan is cell then mrWav is cell for each shank

P = funcDefStr(funcInStr(varargin{:}), ...
    'readDuration', [], 'viChan', [], 'fid', [], ...
    'freqLim', [], 'fMeanSubt', 0, 'chOffset', 0);

[vcFilePath, vcFileName, vcFileExt] = fileparts(vcFullPath);
if isempty(vcFilePath), fname_pre = vcFileName;
    else fname_pre = [vcFilePath, '\' vcFileName]; end
try
    S = read_whisper_meta([fname_pre, '.meta']); 
catch
    error('No meta file exists');
    mrWav = [];
    S = [];
    return;
end

% load data and convert units
if isempty(P.fid)
    fid = fopen([fname_pre, '.bin'], 'r'); 
else
    fid = P.fid; 
end
if isempty(P.readDuration)
    nSamples = floor(S.fileSizeBytes/2/S.nChans); 
else
    if numel(P.readDuration) == 2
        nBytesSkip = round(S.nChans * P.readDuration(1) * S.sRateHz * 2);
        fseek(fid,  nBytesSkip, -1);
        P.readDuration = P.readDuration(2);
    end
    nSamples = round(P.readDuration * S.sRateHz); 
end

tic
[mrWav, nBytesRead] = fread(fid, [S.nChans nSamples], 'int16=>single');
tLoadDuration = toc;
if nargout < 3, fclose(fid); end

if nBytesRead < (S.nChans * nSamples)
    nSamplesReq = nSamples;
    nSamples = floor(nBytesRead/S.nChans);
    mrWav = mrWav(1:S.nChans, 1:nSamples);
    fprintf('Read less number of samples (%d) than requested (%d).\n', ...
        nSamples, nSamplesReq);
end
S.tLoaded = nSamples / S.sRateHz;
fprintf('File loading took %0.3f s, x%0.2f realtime.\n', ...
    tLoadDuration, S.tLoaded/tLoadDuration);

%----------------------------------
% filter data
%Scale the channel and convert to double
MAGIC_CONST = (384);  % Our best guess as to why Mladen's data are off
ADC_bits = 16; %number of bits of ADC [was 16 in Chongxi original]
scale = ((S.rangeMax-S.rangeMin)/(2^ADC_bits))/S.auxGain * 1e6;  %uVolts
if ~isempty(P.freqLim)
    [vrFiltB, vrFiltA] = butter(4, P.freqLim / S.sRateHz * 2,'bandpass');    
else
    vrFiltA = [];
end
if isempty(P.viChan), P.viChan = 1:S.nChans; end
if ~iscell(P.viChan), P.viChan = {P.viChan}; end
% if P.fMeanSubt == 3
%     viChan1 = cell2mat(P.viChan);
%     mrWav1 = mrWav(:,viChan1);
%     nChan1 = numel(viChan1);
%     for iChan1 = 1:nChan1
%         iChan = viChan1(iChan1);
%         mrWav1(:,iChan1) = mrWav(:,iChan) - ...
%             mean(mrWav(:,setdiff(viChan1, iChan)),2);
%     end
%     mrWav(:,viChan1) = mrWav1;
% end
cmWav = cell(size(P.viChan));
cmWavRef = cell(size(P.viChan));
for iShank1 = 1:numel(P.viChan)
    mrWav1 = mrWav(P.viChan{iShank1}+P.chOffset,:)';
    % Filter or scale
    if ~isempty(vrFiltA)
        mrWav1 = filter(vrFiltB*scale, vrFiltA, mrWav1); %filter data    
    else
    	mrWav1 = mrWav1 * scale;
    end
    if P.fMeanSubt == 0 
        if isempty(vrFiltA)
            mrWav1 = mrWav1 - MAGIC_CONST;
        end
        mrWavRef = [];
    else
        [mrWav1, mrWavRef] = subtWavMean(mrWav1, P.fMeanSubt);
    end

    cmWav{iShank1} = mrWav1;
    cmWavRef{iShank1} = mrWavRef;
end
S.cmWavRef = cmWavRef;