function [C, D] = load_features(directory, all_files, n_files, custom_sift_bool)
%LOAD_FEATURES Loads all of the feature set
%   
print_start("loading features")

% Check if coordinates and descriptors were already computed
if exist(strcat(directory, 'C.mat')) && exist(strcat(directory, 'D.mat'))
    load(strcat(directory, 'C.mat'));
    load(strcat(directory, 'D.mat'));
    
    disp("C & D were loaded from C.mat & D.mat");
    print_end("loading features")
    return
end

% Initialize coordinates C and descriptors D
	C = {};
	D = {};

% Load all features (coordinates and descriptors of interest points)
% Each feature is a combination of the haraff and hesaff sift features

for i=1:n_files
    name = all_files(i).name;

    % Choose between methods
    if custom_sift_bool == 0
        [coord_haraff,desc_haraff,~,~] = loadFeatures(strcat(directory, name, '.haraff.sift'));
        [coord_hesaff,desc_hesaff,~,~] = loadFeatures(strcat(directory, name, '.hesaff.sift'));

        coord= [coord_haraff coord_hesaff];
        desc = [desc_haraff desc_hesaff];

        C{i} = coord(1:2, :);
        D{i} = desc;

        % Plot 
% 			im = im2double( rgb2gray( imread(strcat(directory, name) ) ) );
% 			figure
% 			imshow(im,[]);
% 			hold on
% 			vl_plotsiftdescriptor(desc,coord(1:4,:));
% 			vl_plotframe(coord);

        print_progress("Loaded features: ", (i/n_files) , name);

    else
        % perform custom sift
        name = all_files(i).name;
        im = im2double( rgb2gray( imread(strcat(directory, name) ) ) );

        % VLfeat parameters
        peak_thresh = 0.15;
        edge_thresh = 15;
        levels = 5;
        octave = -1; %def = 0
        [coord, desc] = vl_sift( single(im), 'Levels', levels, 'FirstOctave',...
            octave, 'PeakThresh', peak_thresh, 'Levels', levels, 'EdgeThresh', edge_thresh);

        % uncomment lines below for plot of descriptors
% 			figure
% 			imshow(im,[]);
% 			hold on

% 			perm = randperm(size(coord,2)) ;
% 			sel = perm(1:2000);
% 			vl_plotsiftdescriptor(desc(:,sel),coord(:,sel)) ;
% 			vl_plotframe(coord(:,sel));

        C{i} = coord(1:2, :);
        D{i} = desc;

        print_progress("Loaded features: ", (i/n_files) , name);
    end
end

% Save the coordinates and descriptors
save(strcat(directory, 'C.mat'), 'C');
save(strcat(directory, 'D.mat'), 'D');

print_end("loading features")

end

