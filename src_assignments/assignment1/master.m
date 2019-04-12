%% Script for testing
clear; delfigs;

pic = 'zebra.png';
sigma = 1;

[imIn,~] = imread(pic);
if (length(size(imIn)) == 3)
    imIn = imIn(:,:,2);
end

%% Run gaussian filtering comparison

% Matlab
G = fspecial('gaussian',sigma);
imMat_corr = imfilter(imIn,G,'same', 'corr');
imMat_conv = imfilter(imIn,G,'same', 'conv');

% Own
imOwn = gaussianConv(imIn,sigma,sigma);

% Show pictures
figure(1); imshow(imIn,[]); title('Original');
figure(2); imshow(imOwn,[]); title('Own Function');
figure(3); imshow(imMat_corr,[]); title('Matlab correlation');
figure(4); imshow(imMat_corr,[]); title('Matlab convolution');

showfigs;

%% Run gradmag function

% First smooth for better results
imIn = gaussianConv(imIn,sigma,sigma);

% Now compute gradient and magnitude
[magnitude, orientation] = gradmag(imIn,sigma);

% Show pictures
figure(1);
imshow(imIn,[]);
title('Smoothed original');

figure(2); 
quiver(magnitude, orientation);
set(gca,'YDir','reverse');
title('Quiver plot of magnitude and orientation');

figure(3);
imshow(orientation, [-pi,pi]);
colormap(hsv);
colorbar;
title('Orientation plot');

figure(4);
imshow(magnitude, []);
title('Magnitude plot');

figure(5);
imshow(treshold(magnitude,0.3))
title('Treshold on magnitude');

showfigs;

%% Run imageDerivates on black picture
% QUESTION: why are the pictures upside down, compared to slides CV.01??
% Is this because picture y=0 is lefttop point and figure y=0 is leftdown point?
delfigs;
types = ["zero", "x", "y", "xx", "yy", "xy", "yx"];
sigma = 10;
imIn = zeros(100,100);
imIn(40:60,40:60) = 1;

for i = 1:length(types)
    figure(i);
    im = imageDerivates(imIn,sigma,types(i));
    imshow(im, []);
    title("Derivate in " + types(i));
end
showfigs;

%% Run imageDerivates on picture
delfigs;
types = ["zero", "x", "y", "xx", "yy", "xy", "yx"];
sigma = 3;

% First smooth for better results
imIn = gaussianConv(pic,sigma,sigma);

for i = 1:length(types)
    figure(i);
    im = imageDerivates(imIn,sigma,types(i));
    imshow(im, []);
    title("Derivate in " + types(i));
end
showfigs;


