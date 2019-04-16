function Gd = gaussianDer_final(G, sigma)

% window extent should be 3 times sigma
extent = ceil(3 * sigma);
% make sure that there is a 'center pixel'
x = -extent:extent;

% Formula for the Gaussian derivative

Gd = -(x/(sigma^2)).*G;

end