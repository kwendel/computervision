%% Test for image align
im1 = imread('boat/img1.pgm');
im2 = imread('boat/img2.pgm');

for i = 1:5
    figure
    imshow(imread("boat/img"+i+".pgm"));
end

% [aff,m1,m2] = imageAlign(im1,im2);

%% Test for mosaic - left and right images
delfigs;
% Load images
im1 = rgb2gray(im2double(imread('left.jpg')));
im2 = rgb2gray(im2double(imread('right.jpg')));

mosaic(im1,im2);

%% Test for mosaic - boat images

im1 = im2double(imread('boat/img1.pgm'));
im2 = im2double(imread('boat/img2.pgm'));
im3 = im2double(imread('boat/img3.pgm'));
im4 = im2double(imread('boat/img4.pgm'));
im5 = im2double(imread('boat/img5.pgm'));

% mosaic(im5,im4,im3,im2,im1);
mosaic(im1,im2, im3, im4);
% , im3, im4, im5);