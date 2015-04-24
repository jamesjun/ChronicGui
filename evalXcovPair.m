function evalXcovPair(trSpkWav, trSpkWavExt, varargin)
P = funcDefStr(funcInStr(varargin{:}), 'nLags', 5);

mrXcovI23 = calcXcovPair(trSpkWav, 'viChan', [2,3], 'nLags', P.nLags);
mrXcovI34 = calcXcovPair(trSpkWav, 'viChan', [3,4], 'nLags', P.nLags);

mrXcovE23 = calcXcovPair(trSpkWavExt, 'viChan', [2,3], 'nLags', P.nLags);
mrXcovE34 = calcXcovPair(trSpkWavExt, 'viChan', [3,4], 'nLags', P.nLags);

vrCvRat23 = cv(mrXcovE23') ./ cv(mrXcovI23');
vrCvRat34 = cv(mrXcovE34') ./ cv(mrXcovI34');

figure;
bar(-P.nLags:P.nLags, [vrCvRat23; vrCvRat34]');
xlabel('nLags');
ylabel('CV ratio');