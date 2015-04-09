function mr = filtFibo3(mr)
vrStart = mr(1,:);
vrEnd = mr(end,:);

mr = (2*mr(2:end-1,:) + mr(1:end-2,:) + mr(3:end,:))/4;
mr = [vrStart; mr; vrEnd];