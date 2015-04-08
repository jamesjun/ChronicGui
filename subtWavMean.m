function [mrWav1, mrWavRef] = subtWavMean(mrWav1, fMeanSubt)
mrWavRef = [];

% Mean subtract
switch fMeanSubt
    case 0 % no mean subtraction
        return;
    case 1 % simple mean subtraction
        mrWav1 = bsxfun(@minus, mrWav1, mean(mrWav1, 2)); 
    case 2 % excluded mean
        mrWav2 = mrWav1;
        nChan1 = size(mrWav1,2);
        for iChan = 1:nChan1
            mrWav1(:,iChan) = mrWav2(:,iChan) - ...
                mean(mrWav2(:,setdiff(1:nChan1, iChan)),2);
        end
    case 3 % use all channels to subtract mean
        disp('');%processed already, do nothing
    case 4 % linear fitting to subtract channel
        [~, mrWav1] = subtMeanFit(mrWav1);
    case 5 %just do this for peak-to-peak computation
        mrWavRef = subtMeanFit(mrWav1);
    case 6 % simple mean subtraction
        mrWav1 = bsxfun(@minus, mrWav1, median(mrWav1, 2)); 
    otherwise
        error('wrong fMeanSubt');
end %switch