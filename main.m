%{
IN4393 - Computer Vision

Group 33
Kasper Wendel
Thijs van der Burg

Main script that call the different components of the assignment
%}

% Clean up
clc; clear; close all;

% Relative paths to the models
castle_path = "models/castle_features/";
teddy_path = "models/teddybear_features/";

% Pick model to use in 3D reconstruction
model_directory = teddy_path;

% Get all .png files in the directory
all_files=dir(strcat(model_directory, '*.png'));
n_files = length(all_files);

if n_files == 0
    error("Directory contained no files!!");
end

% Find/Load interest points between consecutive images
% Caution: Loads C.mat, D.mat if present in the directory
[C,D] = load_features(model_directory, all_files, n_files);

% TODO: use the vl_feature lib for extracting features
% [C,D,Matches,n_files] = extract_features(teddy_path);
% EXTRA: Harris corners + matching

% Find best matches using 8-point RANSAC
% Caution: Loads Matches.mat if present in the directory
[Matches] = find_matches(model_directory, C,D,n_files);

% Chain images: create pointview (PV) matrix 
[PV] = chain_images(model_directory, Matches);

% Stitching: with affine Structure from Motion
% Stitch every 3 images together to create a point cloud.
[mergedCloud, M1, MeanFrame1] = stitch_images(n_files, PV, C);

% EXTRA: Render surface + texture based on the first image
first_img = im2double(imread(strcat(model_directory, all_files(1).name)));
render_surface(mergedCloud, M1, MeanFrame1, first_img);