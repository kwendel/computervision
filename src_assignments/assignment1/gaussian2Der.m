function Gd = gaussian2Der(G, sigma)
%GAUSSIAN2DER Computes second order derivative of Gaussian

% Compute the original x range of G
% extent is 3*sigma
r = ceil(3*sigma);
x = -r:1:r;

% Compute second order derivative
Gd = ((-sigma^2 + x.^2) / sigma^4) .* G;

end

