% This function incorporates all the required steps for the final project. 
% Please pay attention to expected data formats and data sizes.

% function [] = reconstruction_demo()

    % Open the specified folder and read images. 
%     directory = "assignment6/TeddyBearPNG/"; % Path to your local image directory 
    directory = "computervision/models/teddybear_features/"; % Path to your local image directory 
    Files=dir(strcat(directory, '*.png'));
    n = length(Files);

    % Apply normalized 8-point RANSAC algorithm to find best matches. (Lab assignment 3+5)
    % The output includes cell arrays with Coordinates (C), Descriptors (D) and indies (Matches)for all matched pairs.
    disp('ransac_match');
    if exist(strcat(directory, 'Matches.mat')) && exist(strcat(directory, 'C.mat'))
        load(strcat(directory, 'Matches.mat'));
        load(strcat(directory, 'C.mat'));
    else
        [C,D, Matches] = ransac_match(directory);
        save(strcat(directory, 'Matches.mat'), 'Matches');
        save(strcat(directory, 'C.mat'), 'C');
    end

    % Chaining: Create point-view matrix (PV) to represent point correspondences 
    % for different camera views (Lab assignment 6).
    disp('chainimages');
    if exist(strcat(directory, 'PV.mat'))
        load(strcat(directory, 'PV.mat'));
    else
        [PV] = chainimages(Matches);
        save(strcat(directory, 'PV.mat'), 'PV');
    end


    % Stitching: with affine Structure from Motion
    % Stitch every 3 images together to create a point cloud.
    Clouds = {};
    i = 1;
    numFrames=3;

    for iBegin = 1:n-(numFrames - 1)
        iEnd = iBegin + (numFrames - 1);
        
        % Select frames from the PV matrix to form a block
        block = PV(iBegin:iEnd,:);
        
        % Select columns from the block that do not have any zeros
        colInds = find(all(block ~= 0));
        
        % Check the number of visible points in all views
        numPoints = size(colInds, 2);
        if numPoints < 8
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
        if size(sharedPoints, 2) < 15
            disp("Not enough points:");
            disp(size(sharedPoints,2));
            disp("Clouds:");
            disp(i);
            continue
        end
        
        % Find optimal transformation between shared points using procrustes
        [d, Z, T] = procrustes(mergedCloud(:,sharedInds)', sharedPoints');
        
        % Find the points that are not shared between the merged cloud and the Clouds{i,:} using "setdiff" over indexes
        [iNew, iCloudsNew] = setdiff(newInds, mergedInds);
        
        % T.c is a repeated 3D offset, so resample it to have the correct size
        c = T.c(ones(size(iCloudsNew,2),1),:);

        % Transform the new points using: Z = (T.b * Y' * T.T + T.c)'
        % and store them in the merged cloud, and add their indexes to merged set
        mergedCloud(:, iNew) = (T.b * newPoints(:,iCloudsNew)' * T.T + c)';
        mergedInds           = [mergedInds iNew];
    end

    % Plot the full merged cloud
    % Helpful for debugging and visualizing your reconstruction
    figure;
    X = mergedCloud(1,:)';
    Y = mergedCloud(2,:)';
    Z = mergedCloud(3,:)';
    scatter3(X, Y, Z, 20, [1 0 0], 'filled');
    axis( [-500 500 -500 500 -500 500] )
    daspect([1 1 1])
    rotate3d on;


    % You are free to use other techniques like (Bundle Adjustment) to further
    % improve your reconstruction.


    % 3D Model Plotting (surfaceRender):
    % When you have the 3D point cloud of the moodel, use the built-in surf
    % function for the 3D surface plot. Then include RGB (texture) colour of
    % the related points on surf visualization (interpolate colour values for
    % the filled areas on the surface using the known points). 
    % Students are supposed to implement this in a clever way (by using built-in
    % Matlab functions).
%     surfaceRender(mergedCloud, M1, MeanFrame1, im2double(imread(strcat(directory, Files(1).name))));

% end
