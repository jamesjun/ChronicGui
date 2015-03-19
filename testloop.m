function testloop(ND)
rho = zeros(1,ND);
rho1 = zeros(1,ND);
expdist2 = rand(ND);

for i=1:ND-1
  for j=i+1:ND
     rho(i)=rho(i)+expdist2(i,j);
     rho(j)=rho(j)+expdist2(i,j);
  end
  
    j = i+1:ND;
    rho1(i) = rho1(i)*(ND-i) + sum(expdist2(i,j));
    rho1(j) = rho1(j) + expdist2(i,j);
end