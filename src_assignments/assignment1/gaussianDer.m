function Gd = gaussianDer(G, sigma)
%GAUSSIANDER Computes first order derivative of Gaussian

% Compute the original x range of G
% extent is 3*sigma
r = ceil(3*sigma);
x = -r:1:r;

% Compute first order derivative
Gd = -(x / sigma^2) .* G;

end

