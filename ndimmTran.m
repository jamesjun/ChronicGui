function tr1 = trans3d(tr, dimm1, dimm2)
    size1 = size(tr);
    size1(dimm1) = size(dimm2);
    size1(dimm2) = size(dimm1);
    tr1 = zeros(size1, 'like', tr);
    switch dimm1
        case 1
            switch dimm2
                case 2
                    for i1 = 1:size(tr,dimm1)
                        for i2 = 1:size(tr,dimm2)
                            tr1(i2,i1,:)=tr(i1,i2,:);
                        end
                    end
                case 3
            end
        case 2
            switch dimm2
                case 1
                    
                    
                case 3
            end
        case 3
            switch dimm2
                case 1
                    
                case 2
                    
            end
    end
end