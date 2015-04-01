function [mrSubt, mrWav] = subtMeanFit(mrWav)
% mrWav0 = mrWav;
mrSubt = zeros(size(mrWav,2), 'single');
for iChan = 1:size(mrWav,2)    
    vrY = mrWav(:,iChan);
    mrWav(:,iChan) = 1;    
%     mrWav(:,iChan) = vrY - mrWav1 * (mrWav1 \ vrY );
    mrSubt(:,iChan) = (mrWav \ vrY );
    mrWav(:,iChan) = vrY; %restore
end
mrSubt = eye(size(mrSubt), 'single') - mrSubt;
if nargout >= 2
    mrWav = mrWav * mrSubt;
end