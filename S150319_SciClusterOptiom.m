% S_SciClusterOptimization

%% original output
ND = 10;
% ND1 = 4;
% expdist2 = round(rand(ND));
% disp(expdist2)

%
rho = zeros(1,ND);
rho1 = zeros(1,ND);
expdist2 = magic(ND);
expdist2 = expdist2 + expdist2'; %make symmetric
tic
for i=1:ND-1
    disp(i)
  for j=i+1:ND
%      fprintf('i=%d, j=%d\n', i, j);
     rho(i)=rho(i)+expdist2(i,j);
     rho(j)=rho(j)+expdist2(i,j);
  end
  disp(rho)

  
  for j=i+1:ND
%      fprintf('i=%d, j=%d\n', i, j);
     rho1(i)=rho1(i)+expdist2(i,j);
  end
  
  j = i+1:ND;
  rho1(j) = rho1(j) + (expdist2(i,j));
  disp(rho1)

%  disp(rho);
end
toc %7.053022
% rho1=rho;
% disp(rho(1:ND1))
%     16     2     3    13
%      5    11    10     8
%      9     7     6    12
%      4    14    15     1
% ----------------------------------
%     18     2     3    13
% 
%     18    20    13    21
% 
%     18    20    25    33
    
%% original output
ND = 8;
% ND1 = 4;
% expdist2 = round(rand(ND));
% disp(expdist2)

%
rho = zeros(1,ND);
rho1 = zeros(1,ND);
expdist2 = magic(ND);
expdist2 = expdist2 + expdist2'; %make symmetric
tic
for i=1:ND-1
    disp(i)
  for j=i+1:ND
%      fprintf('i=%d, j=%d\n', i, j);
     rho(i)=rho(i)+expdist2(i,j);
     rho(j)=rho(j)+expdist2(i,j);
  end
  disp(rho)

  j = i+1:ND;
  rho1(i)=rho1(i)+sum(expdist2(i,j));
  rho1(j) = rho1(j) + (expdist2(i,j));
  disp(rho1)

%  disp(rho);
end
toc %7.053022