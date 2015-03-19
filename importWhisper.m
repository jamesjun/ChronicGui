function [mrWav, S, fid] = importWhisper(vcFullPath, varargin)
% read_duration: time duration to read (sec)
% mrWav: in microvolts
% if viChan is cell then mrWav is cell for each shank

P = struct(varargin{:});
if ~isfield(P, 'readDuration'), P.readDuration = []; end %in sec or range
if ~isfield(P, 'viChan'), P.viChan = []; end
if ~isfield(P, 'fid'), P.fid = []; end
if ~isfield(P, 'freqLim'), P.freqLim = []; end
if ~isfield(P, 'fMeanSubt'), P.fMeanSubt = 0; end

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
if isempty(P.fid), fid = fopen([fname_pre, '.bin'], 'r'); 
else fid = P.fid; end
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
[mrWav, nBytesRead] = fread(fid, [S.nChans nSamples], 'int16');
if nBytesRead < (S.nChans * nSamples)
    error('page size less than read_duration');
end
if nargout < 3, fclose(fid); end

%Scale the channel and convert to double
MAGIC_CONST = (384);  % Our best guess as to why Mladen's data are off
ADC_bits = 16; %number of bits of ADC [was 16 in Chongxi original]
scale = ((S.rangeMax-S.rangeMin)/(2^ADC_bits))/S.auxGain * 1e6;  %uVolts
if ~isempty(P.freqLim)
    [vrFiltB, vrFiltA] = butter(4, P.freqLim / S.sRateHz * 2,'bandpass');    
else
    vrFiltA = [];
end

if isempty(P.viChan), P.viChan = 1:size(mrWav,1); end
if ~iscell(P.viChan), P.viChan = {P.viChan}; end

cmWav = cell(size(P.viChan));
for iShank1 = 1:numel(P.viChan)
    mrWav1 = mrWav(P.viChan{iShank1},:)';    
    % Mean subtract
    if P.fMeanSubt
        mrWav1 = bsxfun(@minus, mrWav1, mean(mrWav1, 2)); 
    else
        mrWav1 = mrWav1 - MAGIC_CONST;
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
if numel(cmWav) == 1
    mrWav = cmWav{1}; 
else 
    mrWav = cmWav;
end