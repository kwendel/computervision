%{
IN4393 - Computer Vision

Group 33
Kasper Wendel
Thijs van der Burg

Main script that call the different components of the assignment
%}

%% Settings
% Clean up
clc; clear; close all;

% PARAMETERS
% Relative paths to the models
castle_path = "models/castle/";
teddy_path = "models/teddybear/";

% RANSAC Threshold
ransac_threshold = 10;

% Pick model to use in 3D reconstruction
model_directory = teddy_path;

% CHECK FILES
% Get all .png files in the directory
all_files=dir(strcat(model_directory, '*.png'));
n_files = length(all_files);

if n_files == 0
    error("Directory contained no files!!");
end

% Find/Load interest points between consecutive images
% EXTRA: Harris corners + matching
harris_on = 0;
harris_scale = .7;
harris_thresh = .01;

if harris_on == 1
	[C_harris,D_harris] = harris_features_final(model_directory, all_files, n_files, harris_scale, harris_thresh); 
    C = C_harris; D = D_harris;
else
	% Find/Load interest points between consecutive images
	% Caution: Loads C.mat, D.mat if present in the directory
    
    % 1 for calculating custom SIFT descriptors using vl_sift
    % 0 for loading TA features
	custom_sift_on = 0;
	[C,D] = load_features(model_directory, all_files, n_files, custom_sift_on);
end

% Find best matches using 8-point RANSAC
% Caution: Loads Matches.mat if present in the directory
% Harris implementation enabled when harris_on = 1
vlthresh = 2; %def= 1.5
[Matches] = find_matches(model_directory, C, D, n_files, harris_scale, harris_on, vlthresh);

% Chain images: create pointview (PV) matrix 
[PV] = chain_images(model_directory, Matches, harris_on);

% Stitching: with affine Structure from Motion
% Stitch every 3 images together to create a point cloud.
[mergedCloud, M1, MeanFrame1] = stitch_images(n_files, PV, C);

% EXTRA: Render surface + texture based on the first image
first_img = im2double(imread(strcat(model_directory, all_files(1).name)));
render_surface(mergedCloud, M1, MeanFrame1, first_img);