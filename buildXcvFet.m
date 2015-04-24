function mrFet = buildXcvFet(trSpkWav, varargin)
P = funcDefStr(funcInStr(varargin{:}), ...
        'fMix', 0, 'nLag', 3);

nSpks = size(trSpkWav, 3);
nChans = size(trSpkWav, 2);
nSamples = size(trSpkWav, 1);
mrFet = zeros(nChans * (P.nLag*nChans-1), nSpks);

for iSpk=1:nSpks
    mr = double(trSpkWav(:,:,iSpk));
    %mr = bsxfun(@minus, mr, sum(mr)); %subtract mean
     if P.fMix
         mr0=mr;
         for iChan=1:nChans
             viChan1 = setdiff(1:nChans, iChan);
            mr(:,iChan) = mr0(:,iChan)*.5 + .5/(nChans-1)*sum(mr0(:,viChan1), 2);
         end
     end
    
    viRange = 1:(P.nLag * nChans - 1);
    mrLag = zeros(nSamples-P.nLag+1, P.nLag*nChans-1);
    for iChan = 1:nChans
        viRange1 = 1:nChans;
        viChan = 1:nChans;
        for iLag = 1:P.nLag
            if iLag == P.nLag
                viRange1(end) = [];
                viChan = setdiff(1:nChans, iChan);
            end
            mrLag(:,viRange1) = mr(iLag:nSamples-P.nLag+iLag,viChan);
            viRange1 = viRange1 + nChans;
        end
        mrFet(viRange,iSpk) = mr(P.nLag:end,iChan) \ mrLag;
        viRange = viRange + numel(viRange);
    end
end