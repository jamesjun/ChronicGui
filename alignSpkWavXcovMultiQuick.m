
function [tr, vr0] = alignSpkWavXcovMultiQuick(tr, varargin)
% shift all channels
%nTrim=4
P = funcDefStr(funcInStr(varargin{:}), ...
    'viChan', [], 'maxLag', 10, 'nRepeat', 10, 'nRepeatMin', 3, ...
    'nTrim', 0, 'trimLim', [], 'alignPower', 1, 'viClu', [], 'nPadding', 0);

nSpks = size(tr,3);
nSamples = size(tr,1);
nChans = size(tr,2);
viRange0 = 1:nSamples;
if isempty(P.viChan)
    P.viChan = 1:nChans;
end

% recursive call
if ~isempty(P.viClu) && numel(size(tr)) == 3
    P1 = P;
    P1.viClu = [];
    vr0 = median(tr(:,P.viChan,:),3);
    vr0 = vr0(:) .^ P.alignPower; %global template
    for iClu=1:max(P.viClu)
        viSpk = find(P.viClu == iClu);
        [tr1, vr1] = alignSpkWavXcovMultiQuick(tr(:,:,viSpk), P1);
        [vrXcv, vnLags] = xcov(vr0, vr1, P.maxLag, 'coef');
        [~, iLag] = max(vrXcv);
        viRange = mod(viRange0 - vnLags(iLag) - 1, nSamples)+1;
        tr(:,:,viSpk) = tr1(viRange,:,:);
    end          
    return;
end

vr0 = [];
% fig=figure;
fprintf('nShift = ');
switch numel(size(tr))
    case 3
        nShiftPrev = inf;
        for iRepeat=1:P.nRepeat
            nShift = 0;
            vr0 = median(tr(:,P.viChan,:),3);
            vr0 = vr0(:) .^ P.alignPower;
%             figure(fig); plot(vr0); title('template');
            tr0=tr;
            for iSpk=1:nSpks
                vr = tr(:,P.viChan,iSpk);
                vr = vr(:) .^ P.alignPower;
                [vrXcv, vnLags] = xcov(vr0, vr, P.maxLag, 'coef');
                [~, iLag] = max(vrXcv);
                if vnLags(iLag) ~= 0
                   nShift = nShift+1;
                   viRange = mod(viRange0 - vnLags(iLag) - 1, nSamples)+1;
                    tr(:,:,iSpk) = tr(viRange,:,iSpk); %waveform shifted, move other channels
                end
            end
            fprintf('%d, ', nShift);
            if nShiftPrev <= nShift && iRepeat > P.nRepeatMin
                tr=tr0; %undo
                break;
            end
            if nShift == 0
                break;
            end
            %commit
            nShiftPrev = nShift;
        end        
        if P.nTrim > 0
            tr = tr(P.nTrim+1:end-P.nTrim,:,:);
        end
        if ~isempty(P.trimLim)
            tr = trimSpkWav(tr, P.trimLim);
        end
    case 2
        nSpks = size(tr,2);
        nShiftPrev = inf;
        for iRepeat=1:P.nRepeat
            vr0 = mean(tr,2); %template
            nShift = 0;
            for iSpk=1:nSpks
                vr = tr(:,iSpk);
                [vrXcv, vnLags] = xcov(vr0, vr, P.maxLag, 'coef');
                [~, iLag] = max(vrXcv);
                if vnLags(iLag) ~= 0
                   nShift = nShift+1;
                end
                viRange = mod(viRange0 - vnLags(iLag) - 1, nSamples)+1;
                tr(:,iSpk) = vr(viRange); %waveform shifted
            end
            if nShiftPrev <= nShift && iRepeat > P.nRepeatMin
                break;
            end    
            nShiftPrev = nShift;
            fprintf('%d, ', nShift);
        end
        if ~isempty(P.nTrim)
            tr = tr(P.nTrim+1:end-P.nTrim,:);
        end
end %switch
fprintf('\n');
end %function


function test()
mrA = repmat(sin(0:.1:2*pi)', [1,1,10]);
mrA(:,:,5) = [mrA(5:end,:,1); mrA(1:4,:,1)];
figure; imagesc(mrA(:,:,5));
end