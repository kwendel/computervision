function [mergedCloud, M1, MeanFrame1] = stitch_images(n_files,PV, C)
%STITCH_IMAGES Summary of this function goes here
%   Detailed explanation goes here

print_start("stitching images");

% Stitching: with affine Structure from Motion
% Stitch every 3 images together to create a point cloud.
Clouds = {};
i = 1;
numFrames = 3;

for iBegin = 1:n_files-(numFrames - 1)
    iEnd = iBegin + (numFrames - 1);

    % Select frames from the PV matrix to form a block
    block = PV(iBegin:iEnd,:);

    % Select columns from the block that do not have any zeros
    colInds = find(all(block ~= 0));

    % Check the number of visible points in all views
    numPoints = size(colInds, 2);
    if numPoints < 8
        fprintf("Not enough points frame %d -- %d",iBegin,iEnd);
        continue
    end


    % Create measurement matrix X with coordinates instead of indices using the block and the 
    % Coordinates C 
    block = block(:, colInds); 
    X = zeros(2 * numFrames, numPoints);
    for f = 1:numFrames
        for p = 1:numPoints
            X(2 * f - 1, p) =  C{iBegin + f - 1}(1,block(f,p));
            X(2 * f, p)     =  C{iBegin + f - 1}(2,block(f,p));
        end
    end


    % Estimate 3D coordinates of each block following Lab 4 "Structure from Motion" to compute the M and S matrix.
    % Here, an additional output "p" is added to deal with the non-positive matrix error
    % Please check the chol function inside sfm.m for detail.
    [M, S, p] = sfm(X); % Your structure from motion implementation for the measurements X

    % Save the M matrix and Meanvalues for the first frame. In this example,the
    % first frame is the camera plane (view) where every point will be projected
    % Please do check if M is non-zero before selection. Otherwise, you
    % have to select another view
    if i==1 && ~p
        M1=M(1:2,:);
        MeanFrame1=sum(X,2)/numPoints;
    end

    if ~p
        % Compose Clouds in the form of (M,S,colInds)
        Clouds(i, :) = {M, S, colInds};
        i = i + 1;
    end
end

% By an iterative manner, stitch each 3D point set to the main view using the point correspondences i.e., finding optimal
% transformation between shared points in your 3D point clouds. 

% Initialize the merged (aligned) cloud with the main view, in the first point set.
mergedCloud                 = zeros(3, size(PV,2));
mergedCloud(:, Clouds{1,3}) = Clouds{1,2};  
mergedInds                  = Clouds{1,3}; 

% Stitch each 3D point set to the main view using procrustes
numClouds = size(Clouds,1);
for i = 2:numClouds
    newInds = Clouds{i,3};
    newPoints = Clouds{i,2};

    % Get the points that are in the merged cloud and the new cloud by using "intersect" over indexes
    [sharedInds, ~, iClouds] = intersect(mergedInds, newInds);
    sharedPoints             = newPoints(:,iClouds);

    % A certain number of shared points to do procrustes analysis.
    shared_threshold = 2;
    if size(sharedPoints, 2) < shared_threshold
        fprintf("Stitching error - not enough point for procrustes for Cloud %d \n", i);
        fprintf("Threshold: %d -- Have: %d \n",shared_threshold,size(sharedPoints,2));
        continue
    end

    % Find optimal transformation between shared points using procrustes
    [~, ~, T] = procrustes(mergedCloud(:,sharedInds)', sharedPoints');

    % Find the points that are not shared between the merged cloud and the Clouds{i,:} using "setdiff" over indexes
    [iNew, iCloudsNew] = setdiff(newInds, mergedInds);

    % T.c is a repeated 3D offset, so resample it to have the correct size
    c = T.c(ones(size(iCloudsNew,2),1),:);

    % Transform the new points using: Z = (T.b * Y' * T.T + T.c)'
    % and store them in the merged cloud, and add their indexes to merged set
    mergedCloud(:, iNew) = (T.b * newPoints(:,iCloudsNew)' * T.T + c)';
    mergedInds           = [mergedInds iNew];
    
    % Plot intermediate results
%     figure;
%     X = mergedCloud(1,:)';
%     Y = mergedCloud(2,:)';
%     Z = mergedCloud(3,:)';
%     scatter3(X, Y, Z, 20, [1 0 0], 'filled');
%     axis( [-500 500 -500 500 -500 500] )
%     % axis( [-750 750 -750 750 -750 750])
%     daspect([1 1 1])
%     rotate3d on;
end

% Plot the full merged cloud
% Helpful for debugging and visualizing your reconstruction
figure;
X = mergedCloud(1,:)';
Y = mergedCloud(2,:)';
Z = mergedCloud(3,:)';
scatter3(X, Y, Z, 20, [1 0 0], 'filled');
axis( [-500 500 -500 500 -500 500] )
% axis( [-750 750 -750 750 -750 750])
daspect([1 1 1])
rotate3d on;

print_end("stitching images");
end

