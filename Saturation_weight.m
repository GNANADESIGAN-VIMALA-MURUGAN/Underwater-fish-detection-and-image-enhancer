
function Wsat = Saturation_weight(img)
[m, n, ~] = size(img);
lab = double(rgb_to_lab(img)/255);
for i = 1 : m
    for j = 1 : n
        Wsat(i,j) = (1/3 * ((img(i,j,1) - lab(i,j,1))^2 ...
                             +  (img(i,j,2) - lab(i,j,1))^2 ...
                             +  (img(i,j,3) - lab(i,j,1))^2) )^0.5;
    end
end
end
