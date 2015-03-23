function P = funcInStr( varargin )
%FUNCINSTR Summary of this function goes here
%   Detailed explanation goes here

if numel(varargin) > 0 
    if isstruct(varargin{1}), P = varargin{1}; 
        else P = struct(varargin{:}); end  
else
    P = struct();
end

