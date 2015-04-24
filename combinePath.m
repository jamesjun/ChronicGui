function cs = combinePath(vc, cs)
for i=1:numel(cs)
    cs{i} = [vc, cs{i}];
end