function trPlot(trWav, varargin)
P = funcDefStr(funcInStr(varargin{:}), ...
        'fOverlap', 1, 'csTitles', {}, 'grid', 'on', 'title', 'Spike table', 'fTrace', 0, 'linestyle', '-', 'nPadding', 0);

nChans = size(trWav,2);
nSamples = size(trWav,1);
AX = [];
viSamples = (P.nPadding+1):(nSamples-P.nPadding);

switch numel(size(trWav))
    case 3
        
    for iChan = 1:nChans
        mrWav = reshape(trWav(viSamples,iChan,:), numel(viSamples), []);    
        if P.fTrace
            mrWav=mrWav(:);
        end
        AX(end+1) = subplot(nChans,1,iChan);
        if P.fOverlap
            plot(mrWav, 'linestyle', P.linestyle);
        else
            plot(mrWav(:), 'linestyle', P.linestyle);
        end
        if ~isempty(P.csTitles)
            title(P.csTitles{iChan});
        end
        grid(P.grid);
    end

    case 2
    for iChan = 1:nChans
        vrWav = trWav(viSamples,iChan);
        AX(end+1) = subplot(nChans,1,iChan);
        plot(vrWav, 'linestyle', P.linestyle);
        if ~isempty(P.csTitles)
            title(P.csTitles{iChan});
        end
        grid(P.grid);
    end
end
linkaxes(AX,'x');
if ~isempty(P.title)
    set(gcf, 'Name', P.title);
end