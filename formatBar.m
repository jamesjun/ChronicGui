function mrMed = formatBar(mrMed)

if size(mrMed, 1) <= 1
    mrMed = [mrMed; zeros(size(mrMed))];
end
