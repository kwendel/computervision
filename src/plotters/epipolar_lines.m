%% Settings BEAR
directory = "models/teddybear_features/";

load(strcat(directory, 'C.mat'));
load(strcat(directory, 'D.mat'));
load(strcat(directory, 'Matches.mat'));

pic_name = "obj02_00";
idx1 = 1;
idx2 = 2;

img1 = im2double(rgb2gray(imread(strcat(directory,pic_name,num2str(idx1),".png"))));
img2 = im2double(rgb2gray(imread(strcat(directory,pic_name,num2str(idx2),".png"))));

ransac_threshold = 1;

% repeatable results
rng(5);

%% Settings CASTLE
directory = "models/castle_features/";

load(strcat(directory, 'C.mat'));
load(strcat(directory, 'D.mat'));
load(strcat(directory, 'Matches.mat'));

idx1 = 1;
idx2 = 2;

img1 = im2double(rgb2gray(imread(strcat(directory,"8ADT8586.png"))));
img2 = im2double(rgb2gray(imread(strcat(directory,"8ADT8587.png"))));

ransac_threshold = 1;

% repeatable results
rng(5);
%% Matchs interest points

% Load variables
coord1 = C{idx1};
coord2 = C{idx2};
desc1 = D{idx1};
desc2 = D{idx2};

% Find matches according to extracted descriptors using vl_ubcmatch
[match, ~] = vl_ubcmatch(desc1,desc2);
disp(strcat( int2str(size(match,2)), ' matches found'));
%% Estimate fundamental matrix

% Obtain X,Y coordinates of matches points
X1 = coord1(1:2,match(1,:));
X2 = coord2(1:2,match(2,:));

% Find inliers using normalized 8-point RANSAC algorithm
[F, inliers] = estimateFundamentalMatrix(X1,X2, ransac_threshold);

% Display Fundamental matrix
disp('F =');
disp(F);

%% Visualize epipolar lines

% Show the images with matched points
figure(1);
imshow([img1,img2],'InitialMagnification', 'fit');
title('Images with matched points'); hold on;

n_inliers = 20;
n_outliers = 10;

in = randi(size(inliers,2),1,n_inliers);

scatter(X1(1,in),X1(2,in), 'y');
scatter(size(img1,2)+X2(1,in),X2(2,in) ,'r');
line([X1(1,in);size(img1,2)+X2(1,in)], [X1(2,in);X2(2,in)], 'Color', 'b');

% outliers = setdiff(1:size(match,2),inliers);
% out = randi(size(outliers,2),1,n_outliers);
% line([X1(1,out);size(img1,2)+X2(1,out)], [X1(2,out);X2(2,out)], 'Color', 'r');

figure(2);
% Visualize epipolar lines
subplot(1,2,1);
imshow(img1,'InitialMagnification', 'fit');
title('Epipolar line for the yellow point of right image'); hold on;
subplot(1,2,2);
imshow(img2,'InitialMagnification', 'fit');
title('Epipolar line for the yellow point of left image'); hold on;

% Take random points and visualize
a  = 1;
b  = size(match,2);
rL = floor(a + (b-a).*rand(1,1));
rR = floor(a + (b-a).*rand(1,1));
pointL = [X1(:,rL);1];
pointR = [X2(:,rR);1];

subplot(1,2,1);
scatter(pointL(1),pointL(2),15,'y');
subplot(1,2,2);
scatter(pointR(1),pointR(2),15,'y');

% If the obtained line has coordinates (u1, u2, u3) then we can plot it over the image (X,Y) with:
% Y = -(u1 * X + u3)/u2
epiR = F * pointL;
plot(-(epiR(1)*(1:size(img2,2))+epiR(3))./epiR(2), 'r')

epiL = F' * pointR;
subplot(1,2,1);
plot(-(epiL(1)*(1:size(img1,2))+epiL(3))./epiL(2), 'r')

figure(3);
% Visualize epipolar lines
subplot(1,2,1);
imshow(img1,'InitialMagnification', 'fit');
title('Multiple epipolar lines for points of the right image'); hold on;
subplot(1,2,2);
imshow(img2,'InitialMagnification', 'fit');
title('Multiple epipolar lines for points of the left image'); hold on;

% Take multiple points and visualize the epipolar lines
linesR = randi(size(match,2),1,50);
linesL = randi(size(match,2),1,50);

for i = 1:20
    epiR = F * [X1(:,linesL(i));1];
    epiL = F' * [X2(:,linesR(i));1];

    subplot(1,2,2);
    plot(-(epiR(1)*(1:size(img2,2))+epiR(3))./epiR(2), 'r')

    subplot(1,2,1);
    plot(-(epiL(1)*(1:size(img1,2))+epiL(3))./epiL(2), 'r')

end