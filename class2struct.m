function P = class2struct(obj)                        
    csFields = fieldnames(obj);
    P = struct();
    for iField=1:numel(csFields)
        try
            eval(sprintf('P.%s = obj.%s;', ...
                csFields{iField}, csFields{iField}));
        catch err
            fprintf('error in obj2struct, %s\n', csFields{iField});
        end
    end
end