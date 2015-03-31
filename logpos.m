function [mr, minval] =logpos(mr, minval)
if nargin < 2
    ml = mr>0;
    minval = min(mr(ml));
    mr(~ml) = minval;
end

mr = log(mr);