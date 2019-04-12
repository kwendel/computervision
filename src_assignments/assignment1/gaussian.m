function G = gaussian(sigma)
%GAUSSIAN 1D discrete Gaussian filter

if sigma == 0 
    G = 1;
    return
end

% Compute the x range of the kernel
% extent is 3*sigma
r = ceil(3*sigma);
G = -r:1:r;

% Compute the factors of the kernel
c = 1 / (sigma*sqrt(2*pi));
G = c * exp( -(G.^2) / (2*sigma^2));

% Normalize that sum(G) = 1 because we did approximation
G = G / sum(G);

end

