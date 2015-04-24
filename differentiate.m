function [data, data0] = differentiate(data, n, fTrim)
%http://en.wikipedia.org/wiki/Finite_difference_coefficient
if nargin==0
    %test
    data = sin(0:.1:2*pi)';
end

if nargin < 3
    fTrim = 0;
end
if nargin < 2
    n = 3;
end
iShift = (n+1)/2;
data0 = data;
switch numel(size(data))
    case 2
        if size(data,2) > 1
            for iChan=1:size(data,2)
                data(:,iChan) = differentiate1(data(:,iChan), n);
            end
        else
            data = differentiate1(data, n);
        end
        if fTrim
            data = data(iShift:end-iShift+1,:);
            if ~isempty(data0)
                data0 = data0(iShift:end-iShift+1,:);
            end
        end
    case 3
        for iChan=1:size(data,2)
            for iSpk=1:size(data,3)
                data(:,iChan,iSpk) = differentiate1(data(:,iChan,iSpk), n);
            end
        end
        if fTrim
            data = data(iShift:end-iShift+1,:,:);
            if ~isempty(data0)
                data0 = data0(iShift:end-iShift+1,:,:);
            end
        end
end

if nargout == 0
    figure; hold on; plot(data0-1, 'k.-'); plot(data, 'r.-');
    title('test output, k:raw, r:diff1');
end

end %func

function data = differentiate1(data, n)
iShift = (n+1)/2;
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
data = filter(-vrFilt, 1, data(:));
viRange = mod((1:numel(data))-1 + iShift-1, numel(data)) + 1;
data = data(viRange); %phase delay
end