function vi = detectMax(mrData, thresh)

    [viUp, viDn, nSpks] = findTrans(sum(mrData,2) < -thresh);
    
    for iSpk=1:nSpks
        [~, iMax] = 
    end
end