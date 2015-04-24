%% spectral_partition: re-order rows/columns to infer groups within similarity matrix
function [s,p] = spectral_partition(s_)
s_(s_<0.3) = 0;
L = laplacian(s_);
[V, D] = arma_eig(L);
% [ ~ , sort_idx] = sort(D, 'ascend');
% smallest_2 = sort_idx(2);
[~, p] = sort(V(:,2)); % V(:,2) is the second smallest eigenvector
s = s_(p,p);
spy(s);
