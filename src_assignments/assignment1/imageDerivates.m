function F = imageDerivates(img, sigma, type)
%IMAGEDERIVATES Computes the 'type' derivative on the image
%   

% Init Gaussians
G = gaussian(sigma);
Gder = gaussianDer(G,sigma);
G2der = gaussian2Der(G,sigma);

% Convert picture to grayscale and doubles
if length(size(img)) == 3
    img = rgb2gray(img);
end
img = im2double(img);

switch type
    case 'zero'
        F = conv2(G', G, img, 'same'); 
    case 'x'
        F = conv2(img, Gder, 'same');
    case 'y'
        F = conv2(img, Gder', 'same');
    case 'xx'
        F = conv2(img, G2der, 'same');
    case 'yy'
        F = conv2(img, G2der', 'same');
    case {'xy', 'yx'}
        F = conv2(Gder, Gder, img, 'same');        
    otherwise
        warning('Type was not recognized: try x/y or any combination of them')
end

end

