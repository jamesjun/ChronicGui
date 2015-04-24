function tr = trShift(tr, n)
%n: shift

if n==0 
    return; 
end
    
nSamples = size(tr,1);
vi = mod((1:nSamples) + n - 1, nSamples) + 1;

if numel(size(tr)) == 3
    tr = tr(vi,:,:);
else
    tr = tr(vi,:);
end