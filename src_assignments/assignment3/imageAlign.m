% (1) Align two images using the Harris corner point detection and the sift match function.
% (2) Use RANSAC to get the affine transformation
% Input:
%       im1 - first image
%       im2 - second image
% Output:
%       affine_transform - the learned transformation between image 1 and image 2
%       match1           - the corner points in image 1
%       match2           - their corresponding matches in image 2
function [affine_transform, match1, match2] = imageAlign(im1, im2)

    % Load Images
%     im1 = im2double(imread('boat/img1.pgm'));
%     im2 = im2double(imread('boat/img2.pgm'));

    % Detect interest points using your own Harris implementation (lab 2).
%     [r1, c1, sigma1]       = harris(im1, loc1);
%     [frames1, descriptor1] = sift(single(im1), r1, c1, sigma1);
% 
%     [r2, c2, sigma2]       = harris(im2, loc2);
%     [frames2, descriptor2] = sift(single(im2), r2, c2, sigma2);
% 
%     % Get the set of possible matches between descriptors from two image.
%     matches = ... % Your lab 2 implementation for fining matches

    % Optional: You can compare with your results with the custom sift implementation 
    [feat1, descriptor1] = vl_sift(single(im1));
    [feat2, descriptor2] = vl_sift(single(im2));
    matches = vl_ubcmatch(descriptor1, descriptor2);
    % Note: In the final project you will be graded for having your own implementation 
    % for the Harris corner point detection and SIFT feature matching". 

    % Find affine transformation using your own Ransac function
    match1 = feat1(1:2,matches(1,:));
    match2 = feat2(1:2,matches(2,:));
    h = ransac_affine(match1, match2, im1, im2);

    % Draw both original images with the other image transformed to the first
    % image below it
    figure;
    subplot(2,2,1); imshow(im1); title('Original Image 1');
    subplot(2,2,2); imshow(im2); title('Original Image 2');

    % Define the transformation matrix from 'best_h' (best affine parameters) 
    affine_transform = [h(1) h(2) h(5);
                        h(3) h(4) h(6);
                        0 0 1 ];

    % First image transformed
    % Transform image 1 to the pose of image 2
    tform1 = maketform('affine', affine_transform');
    im1b = imtransform(im1, tform1, 'bicubic');
    subplot(2,2,4); imshow(im1b); title('Image 1 transformed to image 2')

    % Second image transformed
    % Transform image 2 to the pose of image 1 with the inverse
    tform2 = maketform('affine', inv(affine_transform)');
    im2b = imtransform(im2, tform2, 'bicubic');
    subplot(2,2,3); imshow(im2b); title('Image 2 transformed to image 1')
end
