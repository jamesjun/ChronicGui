function S = getFet1(mrData, P) 
warning off;
try
    S = detectPeaks(mrData, P);
%     if P.fCluster
%         S.Sclu = clusterScience(S.mrPeak, ...
%             'fPlot', P.fPlot, 'vcDist', 'euclidean');
%     end                    
catch
    S = [];
    disp(lasterr());
end
end %getFet1