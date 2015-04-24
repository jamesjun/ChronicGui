function [ L ] = laplacian( A )
%LAPLACIAN Summary of this function goes here
% Detailed explanation goes here
n = size(A,1);
D = zeros(n);
dd = sum(A,2);
for i=1:n
	if (dd(i) ~= 0)
		D(i,i) = dd(i) ^ (-.5);  % works because D is sparse diagonal matrix
	else
		D(i,i) = eps ^ (-.5);  % not really sure what to do if degree = 0
	end
end
L = D * A * D;
