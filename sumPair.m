function [mrWav, viChan1, viChan2] = sumPair(mrWav)
% works for wave and spkwav

nChans = size(mrWav, 2);
viChan1 = repmat(2:nChans, [2 1]); 
viChan1 = viChan1(2:end);
viChan2 = repmat(1:(nChans-1), [2 1]);
viChan2 = viChan2(1:end-1);

switch numel(size(mrWav))
    case 2
        mrWav = mrWav(:,viChan1) + mrWav(:,viChan2);        
    case 3
        mrWav = mrWav(:,viChan1,:) + mrWav(:,viChan2,:);
end