function [trMag, trPhase] = phasePortrait(tr, varargin)
P = funcDefStr(funcInStr(varargin{:}), ...
    'vcPlot', 'none', 'fTrim', 1, 'diffOrder', 3, 'fRescale', 1, ...
    'fSquare', 0, 'fPhaseSmooth', 0);

nChans=size(tr,2);
if P.fPhaseSmooth
    [tr, trD] = filterSG(tr, P.diffOrder);    
else
    trD = differentiate(tr, P.diffOrder);
end
if P.fRescale
    if numel(size(tr)) == 3
        tr = tr / median(toVec(max(max(abs(tr),1))));
        trD = trD / median(toVec(max(max(abs(trD),1))));
    else
        tr = tr / median(toVec(max(abs(tr),1)));
        trD = trD / median(toVec(max(abs(trD),1)));
    end
end
trMag = (tr.^2+trD.^2);
if ~P.fSquare
    trMag = sqrt(trMag);
end
trPhase = atan2(tr, trD);

switch lower(P.vcPlot)
    case 'phase'
        plot(tr2mr(trPhase));
    case 'magnitude'
        trPlot(trMag);
    case 'portrait'
        for iChan = 1:nChans
            mr1 = tr2mr(tr,iChan); 
            mrD1 = tr2mr(trD,iChan); 
            subplot(nChans,1,iChan);
            plot(mr1, mrD1);
            axis equal;
        end
end
        
%         trMag = zeros(size(tr), 'like', tr);
%         trPhase = zeros(size(tr), 'like', tr);
%         for iChan = 1:nChans
%             mr1 = tr2mr(tr,iChan);
%             
%             [mrDiff1, nShift] = differentiate(mr1,P.diffOrder);
%             %mr1 = mr1(2:end-1,:);
%             %mrDiff1 = mrDiff1(2:end-1,:);
%             if P.fRescale
%                 mr1 = mr1 / nanstd(mr1(:));
%                 mrDiff1 = mrDiff1 / nanstd(mrDiff1(:));
%             end
%             mrMag1 = sqrt(mr1.^2+mrDiff1.^2);
%             mrPhase1 = atan2(mr1, mrDiff1);
%             if ~strcmpi(P.vcPlot,'none')
%                 subplot(nChans,1,iChan);
% %                 axis tight;
%                 axis equal;                
%             end
%             switch lower(P.vcPlot)
%                 case 'phase'
%                     plot((mrPhase1(2:end-1,:))); %function of phase?
%                 case 'magnitude'
%                     plot(mrMag1(2:end-1,:));
%                 case 'portrait'
%                     plot(mr1(2:end-1,:), mrDiff1(2:end-1,:));
%             end
%             trMag(:,iChan,:) = mrMag1;
%             trPhase(:,iChan,:) = mrPhase1;
%         end
%         if P.fTrim
%             trMag = trMag(nShift:end-nShift+1,:,:);
%             trPhase = trPhase(nShift:end-nShift+1,:,:);
%         end
end