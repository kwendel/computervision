function [magnitude, orientation] = gradmag(img,sigma)
%GRADMAG Computes magnitude and orientation of the gradient

G = gaussian(sigma);
der = gaussianDer(G,sigma);

x = conv2(img,der, 'same');
y = conv2(img,der', 'same');

magnitude = sqrt(y.^2 + x.^2);
orientation = atan2(y,x);

end

