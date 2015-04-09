function S = file2spikeTable(P)
% whisper system only

if ~isfield(P, 'tLoad'), P.tLoad = 60; end %in sec

readDuration = P.readDuration;
if nargin(readDuration) == 1
    readDuration = [0, readDuration];    
end

nLoad = ceil(diff(readDuration) / P.tLoad);
P.fid = [];
vrTstart = readDuration(1):P.tLoad:readDuration(2);
cvFet =
for iLoad = 1:nLoad
    P.readDuration = [0, P.tLoad] + vrTstart(iLoad);
    P.readDuration(2) = min(readDuration(2), P.readDuration(2)];    
    [cmData, Sfile, P.fid] = importWhisper(vcFullPath, P);
    cvFet = cell(size(cmData));
    P.cmWavRef = Sfile.cmWavRef;
    P.sRateHz = Sfile.sRateHz;    
    for iShank1 = 1:numel(cmData)
        cvFet{iShank1} = buildSpikeTable(cmData{iShank1}, P);
    end    
end

fclose(P.fid); %close file