function tr = alignSpkWav(tr, varargin)
% using neo

P = funcDefStr(funcInStr(varargin{:}), 'iMax', 5, 'viChan', []);

nSpks = size(tr,3);
nSamples = size(tr,1);
nChans = size(tr,2);
viRange0 = 1:nSamples;
if isempty(P.viChan)
    P.viChan = 1:nChans;
end
for iSpk = 1:nSpks
   mr = tr(:,P.viChan,iSpk);
   vr = calcNeo(sum(mr,2));
   [~,imax] = max(vr);
   viRange = mod(imax-P.iMax + viRange0 - 1, nSamples)+1;
   tr(:,P.viChan,iSpk) = mr(viRange,:);
end