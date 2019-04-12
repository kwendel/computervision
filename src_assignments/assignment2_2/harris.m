function [r, c, sigmas] = harris(im, loc)
% inputs: 
% im: double grayscale image
% loc: list of interest points from the Laplacian approximation
% outputs:
% [r,c,sigmas]: The row and column of each point is returned in r and c
%              and the sigmas 'scale' at which they were found

% Calculate Gaussian Derivatives at derivative-scale. 
% NOTE: The sigma is independent of the window size (which dependes on the Laplacian responses).
% Hint: use your previously implemented function in assignment 1 
sigma = 1;
Ix =  imageDerivates(im,sigma,'x');
Iy =  imageDerivates(im,sigma,'y');

% Allocate an 3-channel image to hold the 3 parameters for each pixel
init_M = zeros(size(Ix,1), size(Ix,2), 3);

% Calculate M for each pixel
init_M(:,:,1) = Ix .^2;
init_M(:,:,2) = Iy .^2;
init_M(:,:,3) = Ix .* Iy;

% Allocate R as an 2-channel image that holds R and sigma for each pixel
R = zeros([size(im), 1]);

% Smooth M with a gaussian at the integration scale sigma.
% Keep only points from the list 'loc' that are corners. 
for i = 1:size(loc,1)
    sigma = loc(i,3); % The sigma at which we found this point	
    if ((i>1) && sigma~=loc(i-1,3)) || (i==1)
        M = imfilter(init_M, fspecial('gaussian', ceil(sigma*6+1), sigma), 'replicate', 'same');
    end

    % DoG.m gives [c,r] locations
    row = loc(i,2);
    col = loc(i,1);

    % Compute the cornerness R at the current location
    k = 0.05;
    trace_l = M(row,col,1) + M(row,col,2);
    det_l = M(row,col,1) * M(row,col,2) - M(row,col,3)^2; 
    R(row, col, 1) = det_l - k * trace_l^2;

    % Store current sigma as well
    R(row, col, 2) = sigma;
end
% Display corners
% figure
% imshow(R(:,:,1),[]);

% Set the threshold
threshold = 4e-6;

% Find local maxima
% Dilation will alter every pixel except local maxima in a 3x3 square area.
% Also checks if R is above threshold

% Non max supression	
R(:,:,1) = ((R(:,:,1)>threshold) & ((imdilate(R(:,:,1), strel('square', 3))==R(:,:,1)))) ; 

% Set the return values: coordinates and sigmas
[r,c] = find(R(:,:,1));
sigmas = zeros(size(r,1),1);
for i = 1:size(r,1)
    sigmas(i) = R(r(i),c(i),2);
end

% Display original image with corners points
im = insertShape(im,'circle',[c, r, sigmas],'LineWidth',2, 'Color', 'yellow');
figure
imshow(im);
title('Detected Harris corners');

end
