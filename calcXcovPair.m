function mrXcov = calcXcovPair(trSpk, varargin)
P = funcDefStr(funcInStr(varargin{:}), ...
    'viChan', [2,3], 'nLags', 10);
ich1 = P.viChan(1);
ich2 = P.viChan(end);
nLags = P.nLags;

nSpks = size(trSpk,3);
nSamples = size(trSpk,1);

mr1 = reshape(permute(trSpk(:,ich1,:), [1 3 2]), nSamples,[]);
mr2 = reshape(permute(trSpk(:,ich2,:), [1 3 2]), nSamples,[]);

mrXcov = zeros(nLags*2+1, nSpks);
for iSpk=1:size(mr1,2)
    mrXcov(:,iSpk) = xcov(mr1(:,iSpk),mr2(:,iSpk),nLags, 'none'); %coeff
end

if nargout == 0
    figure; 
    bar(-nLags:nLags, cv(mrXcov'));
    ylabel('cv xcov');
    xlabel('lags');
    title('SD of xcov spike table')
end
