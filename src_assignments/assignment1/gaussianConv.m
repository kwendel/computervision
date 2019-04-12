function imOut = gaussianConv(image,sigma_x, sigma_y)
%GAUSSIANCONV Convolving an image with a 2D Gaussian
%

Gx = gaussian(sigma_x);
Gy = gaussian(sigma_y)';

imOut = conv2(Gy, Gx, image, 'same');
end

