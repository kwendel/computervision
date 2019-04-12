%% Finding harris points in image
delfigs;
pic_path = 'landscape-a.jpg';
im = im2double(imread(pic_path));
loc = DoG(im,0.01);
% TODO Laplacian of Gaussian approach
[r,c,s] = harris(im,loc);

showfigs;

%% Find the descriptors of two images

clear;delfigs;

im1 = im2double(rgb2gray(imread('landscape-a.jpg')));
im2 = im2double(rgb2gray(imread('landscape-b.jpg')));

loc1 = DoG(im1, 0.01);
[r1, c1, s1] = harris(im1, loc1);
% orientation/rotation is zero
frames = [c1';r1';s1';zeros(1,length(r1))];
[coord1,d1] = vl_sift(single(im1), 'frames', frames);

loc2 = DoG(im2, 0.01);
[r2, c2, s2] = harris(im2, loc2);
% orientation/rotation is zero
frames = [c2';r2';s2';zeros(1,length(r2))];
[coord2,d2] = vl_sift(single(im2), 'frames', frames);

%% Find matches

delfigs;

% Draw harris descriptors
% Show images with scatter plot on each image for the features
% Note: Images must be same size
figure; imshow([im1, im2]);
hold on;
scatter(coord1(1,:), coord1(2,:), coord1(3,:), [1,1,0]);
hold on;
scatter(size(im1,2)+coord2(1,:), coord2(2,:), coord2(3,:), [1,1,0]);
drawnow;

match1 = [];
match2 = [];
% Loop over descripters of image 1
for idx1 = 1:size(d1,2)
    % Init distances as INF
    bestDis = Inf;
    secondBestDis = Inf;
    bestmatch = [0 0];
    
    % Loop over descripters of image 2
    for idx2 = 1:size(d2, 2)
        desc1 = double(d1(:,idx1));
        desc2 = double(d2(:,idx2));
        
        % Normalize L2 norm
        desc1 = norm(desc1);
        desc2 = norm(desc2);
        
        % Compute euclidian distance
        dist = abs(desc2-desc1);
        
        % Threshold the distance
        if secondBestDis > dist
            if bestDis > dist
                secondBestDis = bestDis;
                bestDis = dist;
                bestmatch = [idx1 idx2];
            else
                secondBestDis = dist;
            end
        end
    end
    
    if (bestDis / secondBestDis) < 0.8
        pts1 = coord1(:,bestmatch(1));
        pts2 = coord2(:,bestmatch(2));
        % Draw the matched pairs
%         line([pts1(1);size(im1,2)+pts2(1)], [pts1(2); pts2(2)]);
        match1 = [match1, pts1];
        match2 = [match2, pts2];
    end
end
% After the two for-loop, return matches between the images
line([match1(1,:);size(im1,2)+match2(1,:)],[match1(2,:);match2(2,:)]);
        
            

