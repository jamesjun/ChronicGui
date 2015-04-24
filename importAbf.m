function [mrWav, Sfile, csFnames] = importAbf(vcFname, varargin)
P = funcDefStr(funcInStr(varargin{:}), ...
    'fPlot', 1, 'plotSample', 2, 'freqLim', [300 6000], 'timeLim', [], ...
    'chExt', [1,2,4], 'chInt', 3, 'chIin', 5, 'plotLim', [], 'ylim', [-.4 .2], ...
    'fFibo', 1, 'fFiltInt', 0, 'fMerge', 1, 'fIntSubtMed', 0, 'fSpont', 0, ...
    'chIin', 5);

if P.fFiltInt
    P.chFilt = [P.chExt, P.chInt];
else
    P.chFilt = [P.chExt];
end

csFnames = [];
if iscell(vcFname)
    csFnames = vcFname;
else
    [vcDir, vcFile, vcExt] = fileparts(vcFname);
    if isempty(vcExt) %directory name supplied
        switch lower(computer('arch'))
            case 'maci64'
                vcSep = '/';
            case 'win64'
                vcSep = '\';
        end
        vsFileinfo = dir([vcFname, vcSep, '*.abf']);
        nFiles = numel(vsFileinfo);    
        csFnames = cell(nFiles, 1);
        for iFile=1:nFiles
            csFnames{iFile} = [vcFname, vcSep, vsFileinfo(iFile).name];
        end
    end
end

if ~isempty(csFnames)
    nFiles = numel(csFnames);    
    mrWav = cell(nFiles, 1);
    Sfile = cell(nFiles, 1);
    for iFile=1:nFiles
        [mrWav{iFile}, Sfile{iFile}] = importAbf(csFnames{iFile}, P);
    end
    viKeep = ~cellfun(@isempty, mrWav);
    mrWav = mrWav(viKeep);
    Sfile = Sfile(viKeep);
    csFnames = csFnames(viKeep);
    if P.fMerge
        mrWav = cell2mat(mrWav);
    end
    return;
else
    csFnames = {vcFname};
end

[mrWav,si,Sfile]=abfload(vcFname);
Sfile.vcFname = vcFname;
if numel(size(mrWav)) == 3
    mrWav = permute(mrWav, [1, 3, 2]); 
    mrWav = reshape(mrWav, size(mrWav,1)*size(mrWav,2), []);
end
if P.fSpont
    if max(mrWav(:,P.chIin)) > .01;
        mrWav = []; %reject
        return;
    end
end
        
if P.fIntSubtMed
    mrWav(:,P.chInt) = mrWav(:,P.chInt) - median(mrWav(:,P.chInt));
end    
Sfile.sRateHz = 1000000/si;
Sfile.nChans = size(mrWav,2);

mrWav = trimWav(mrWav, P.timeLim, Sfile.sRateHz);
if P.fFibo
    mrWav(:,P.chFilt) = filtFibo3(mrWav(:,P.chFilt));
end
if ~isempty(P.freqLim) %only filter ext
    [vrFiltB, vrFiltA] = butter(4, P.freqLim / Sfile.sRateHz * 2,'bandpass');   
    mrWav(:,P.chFilt) = filtfilt(vrFiltB, vrFiltA, mrWav(:,P.chFilt)); %filter data    
end

% plot traces
if P.fPlot
    [mrPlot, vrT] = trimWav(mrWav, P.plotLim, Sfile.sRateHz);
    if P.plotSample > 1
        mrPlot = mrPlot(1:P.plotSample:end,:);
        vrT = vrT(1:P.plotSample:end);
    end
    figure;
    ax1 = subplot(3,1,1);
    plot(vrT, mrPlot(:,P.chExt));
    if isempty(P.freqLim)
        vcFreq = '[]';
    else
        vcFreq = sprintf('%0.1f-%0.1f', P.freqLim);
    end
    title(sprintf('Extracell, %s Hz', vcFreq));
    grid on;
    
    ax2 = subplot(3,1,2);
    plot(vrT, mrPlot(:,P.chInt));
    title('Intracell');
    grid on;
    
    ax3 = subplot(3,1,3);
    plot(vrT, mrPlot(:,P.chIin));
    title('Current injection');
    grid on;
    
    xlabel('time (s)');
    linkaxes([ax1,ax2,ax3],'x');
    axis tight;
    set(gcf, 'Name', vcFname);
    
    axis(ax1, [vrT(1), vrT(end), P.ylim(1), P.ylim(2)]);
end % fPlot
end %func


function [mrWav, vrT] = trimWav(mrWav, timeLim, sRateHz)
if ~isempty(timeLim)
    nLim = round(timeLim * sRateHz);
    nLim(1) = max(1, nLim(1));
    nLim(2) = min(size(mrWav,1), nLim(2));
    mrWav = mrWav(nLim(1):nLim(2),:);
else
    nLim = [1, size(mrWav,1)];
end
if nargout > 1
    vrT = (nLim(1):nLim(2)) / sRateHz;
end
end %func