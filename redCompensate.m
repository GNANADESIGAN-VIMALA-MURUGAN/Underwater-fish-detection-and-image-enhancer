
function ret = redCompensate(img,window)
alpha = 1;
r = im2double(img(:,:,1));
g = im2double(img(:,:,2));
b = im2double(img(:,:,3));

[height,width,~] = size(img);
padsize = [(window-1)/2,(window-1)/2];
padr = padarray(r, padsize, 'symmetric', 'both');
padg = padarray(g, padsize, 'symmetric', 'both');

ret = img;
for i = 1:height
    for j = 1:width
        slider = padr(i:i+window-1,j:j+window-1);
        slideg = padg(i:i+window-1,j:j+window-1);
        r_mean = mean(mean(slider));
        g_mean = mean(mean(slideg));
        Irc = r(i,j) + alpha * (g_mean - r_mean) * (1-r(i,j)) * g(i,j);
        Irc = uint8(Irc * 255);
        ret(i, j, 1) = Irc;
    end
end
end
