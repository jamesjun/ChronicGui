function cv1 = cv(mr)
cv1 = abs(std(mr)./mean(mr));