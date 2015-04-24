function tr = alignSpkWavXcovMulti(tr, varargin)
% using neo

P = funcDefStr(funcInStr(varargin{:}), 'viChan', [], 'maxLag', 5, 'nRepeat', 10, 'nRepeatMin', 3, 'nTrim', 4);

nSpks = size(tr,3);
nSamples = size(tr,1);
nChans = size(tr,2);
viRange0 = 1:nSamples;
if isempty(P.viChan)
    P.viChan = 1:nChans;
end

switch numel(size(tr))
    case 3
        nShiftPrev = inf;
        for iRepeat=1:P.nRepeat
            nShift = 0;
            for iChan=1:nChans    
                mr = tr2mr(tr,iChan);                
                vr0 = median(mr,2); %template
                for iSpk=1:nSpks
                    vr = mr(:,iSpk);
                    [vrXcv, vnLags] = xcov(vr0, vr, P.maxLag, 'coef');
                    [~, iLag] = max(vrXcv);
                    if vnLags(iLag) ~= 0
                       nShift = nShift+1;
                    end
                    viRange = mod(viRange0 - vnLags(iLag) - 1, nSamples)+1;
                    tr(:,:,iSpk) = tr(viRange,:,iSpk); %waveform shifted, move other channels
                end
            end
            fprintf('nShift=%d\n', nShift);
            if nShiftPrev <= nShift && iRepeat > P.nRepeatMin
                break;
            end                    
            nShiftPrev = nShift;
        end        
        if ~isempty(P.nTrim)
            tr = tr(P.nTrim+1:end-P.nTrim,:,:);
        end
    case 2
        nSpks = size(tr,2);
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
            fprintf('nShift=%d\n', nShift);
        end
        if ~isempty(P.nTrim)
            tr = tr(P.nTrim+1:end-P.nTrim,:);
        end
end %switch

end %function


function test()
mrA = repmat(sin(0:.1:2*pi)', [1,1,10]);
mrA(:,:,5) = [mrA(5:end,:,1); mrA(1:4,:,1)];
figure; imagesc(mrA(:,:,5));
end