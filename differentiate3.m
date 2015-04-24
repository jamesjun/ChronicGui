function data = differentiate3(data, n)
%http://en.wikipedia.org/wiki/Finite_difference_coefficient
if nargin < 2
    n = 3;
end


if size(data,2) > 1
    for iChan=1:size(data,2)
        data(:,iChan) = differentiate3(data(:,iChan), n);
    end
    return;
end

switch n
    case 3
        vrFilt = [-1/2, 0, 1/2];
    case 5
        vrFilt = [1/12, -2/3, 0, 2/3, -1/12];
    case 7
        vrFilt = [-1/60, 3/20, -3/4, 0, 3/4, -3/20, 1/60];
    case 9
        vrFilt = [1/280, -4/105, 1/5, -4/5, 0, 4/5, -1/5, 4/105, -1/280];
end
data = filter(-vrFilt, 1, data);
data = data((numel(vrFilt)-1):end);