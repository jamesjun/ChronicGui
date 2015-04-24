function [vrContra, vrCvInt, vrCvExt] = fetContraRat(trSpkWav, trSpkWavExt, hFunc)
nChans = size(trSpkWav,2);

vrCvInt = zeros(1, nChans);
vrCvExt = zeros(1, nChans);

for iCh=1:nChans
    vrCvInt(iCh) = cv(hFunc(tr2mr(trSpkWav, iCh)));
    vrCvExt(iCh) = cv(hFunc(tr2mr(trSpkWavExt, iCh)));
end

vrContra = vrCvExt ./ vrCvInt;