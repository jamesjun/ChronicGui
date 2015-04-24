function IDX = SpectralNJW( Data, k, sigma )
% Ng, A., Jordan, M., and Weiss, Y. (2002). On spectral clustering: analysis and an algorithm. In T. Dietterich,
% S. Becker, and Z. Ghahramani (Eds.), Advances in Neural Information Processing Systems 14 
% (pp. 849 – 856). MIT Press.

% CONCEPT: Introduced the normalization process of affinity matrix(D-1/2 A D-1/2), 
% eigenvectors orthonormal conversion and clustering by kmeans 

  n = size(Data,1); %Data is n*p

  % calculate the affinity / similarity matrix
  % generate n x n affinity matrix A where n is the number of rows (data
  % points) in data

  disp('calculating the affinity matrix...');
  tic
  A = zeros(n);
  for i=1:n    
    for j=1:n
      if (i ~= j)  % because diagonals are still zeros
        dist = norm(Data(i,:) - Data(j,:)); 
        A(i,j) = exp(-(dist^2)/(2*sigma^2));
      end
    end
  end
  % A = AffinityMexP(Data',sigma);
  % A = SimilarityMexP(Data');
  toc
  
  % compute the degree matrix - actually D^(-.5)
  disp('calculating the degree matrix...');
  tic
  D = zeros(n);
  dd = sum(A,2);
  for i=1:n
    if (dd(i) ~= 0)
      D(i,i) = dd(i) ^ (-.5);  % works because D is sparse diagonal matrix
    else
      D(i,i) = eps ^ (-.5);  % not really sure what to do if degree = 0
    end
  end
  toc

  % compute normalized laplacian
  disp('calculating the normalized laplacian...');
  tic
  L = D * A * D;
%   L = arma_multiply(D,A);
%   D = gpuArray(D);
%   A = gpuArray(A);
%   tic;
%   L = mtimes(D,A);
%   L = mtimes(L,D);
  toc;
%   L = mtimes(L,D);
%   L = gather(L);
  % find eigenvectors
%   tic;
%   [EigVec,EigVal] = eig(L);
%   toc;

  disp('calculating the eigen vectors...');
  [EigVec,EigVal] = arma_eig(L);
  
  
%   eigenValues = diag(EigVal);   % for matlab built-in eig
%   [ ~ , sort_idx] = sort(eigenValues, 'descend');   %for matlab built-in eig
  
  [ ~ , sort_idx] = sort(EigVal, 'descend'); %   for Armadillo-MKL eig
  % top k indexes in eigenvector matrix
  largest_k = sort_idx(1:k);
  
  % select k largest eigenvectors
  X = EigVec(:, largest_k);
  
  % construct the normalized matrix Y from the obtained eigen vectors
  Y = bsxfun(@rdivide, X, sqrt(sum(X.^2, 2)));
  
  [IDX,C] = kmeans(Y,k); 

end
