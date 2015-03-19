% S150210_load neuralynx
function [mrData, S] = importNlxCsc(vcFullPath, readDur, viChanRead)
% mrData: channel data
% S: file meta
% returns in Whisper channel order

[vcFilePath, vcFileName, vcFileExt] = fileparts(vcFullPath);
% vcFilePath = 'D:\ANM282996\2015-01-07_14-13-22\';
iADBitVolts = 16;
iSR = 14; %sampling rate index
if nargin < 2, readDur = []; end
if nargin < 3
    nChans = 64;
    viChanRead = 1:nChans;
else
    nChans = numel(viChanRead);
end

mrData = [];
for iChan = 1:numel(viChanRead)
    iCsc = viChanRead(iChan);
    vcFullPath = [vcFilePath, sprintf('\\CSC%d.ncs', iCsc)];
    try
        [Samples, Header] = Nlx2MatCSC(vcFullPath, [0 0 0 0 1], 1, 1, [] );
    catch
        disp(lasterr)
    end
    if isempty(mrData)
        vcADBitVolts = Header{iADBitVolts};
        ADBitVolts = str2double(vcADBitVolts(strfind(vcADBitVolts, ' ')+1:end));
        vcsRateHz = Header{iSR};
        sRateHz = str2double(vcsRateHz(strfind(vcsRateHz, ' ')+1:end));    
        if isempty(readDur)
            nData = size(Samples,1) * size(Samples,2);
        else
            nData = round(sRateHz * readDur);
        end
        mrData = zeros(nData, nChans);
    end
    try
        mrData(:, iChan) = Samples(1:nData) * (ADBitVolts * 1e6);
    catch
        disp(lasterr);
    end
end

S = struct('sRateHz', sRateHz, 'nChans', nChans); %outputs in microvolts