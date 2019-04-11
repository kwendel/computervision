function [Matches] = find_matches(directory, C, D, n_files)
%MATCH Match the given coordinates and their descriptors using the 8 points
% RANSAC algorithm

print_start("matching with RANSAC");

% Check if matches were already computed
if exist(strcat(directory, 'Matches.mat'))
    load(strcat(directory, 'Matches.mat'));
    
    disp("Matches were loaded from Matches.mat");
    print_end("matching with RANSAC");
    return
end

% Initialize Matches (between each two consecutive pairs)
Matches={};

for i=1:n_files

    % Get the consecutive image. For the last image, this will be the first 
    % image as we rotate 360 degrees around the object of interest
    next = i+1;        
    if next > n_files
        next = 1;
    end

    % Get coordinates and their descriptors
    coord1 = C{i};
    desc1  = D{i};
    coord2 = C{next};
    desc2  = D{next};
    
    % Find matches according to extracted descriptors using vl_ubcmatch
    [match, ~] = vl_ubcmatch(desc1,desc2);
    disp(strcat( int2str(size(match,2)), ' matches found'));

    % Obtain X,Y coordinates of matches points
    match1 = coord1(1:2,match(1,:));
    match2 = coord2(1:2,match(2,:));

    % Find inliers using normalized 8-point RANSAC algorithm
    [~, inliers] = estimateFundamentalMatrix(match1,match2);
    Matches{i} = match(:,inliers);

    print_progress("Matched file: ", (i / n_files), num2str(i));
end

% Save the matches 
save(strcat(directory, 'Matches.mat'), 'Matches');

print_end("matching with RANSAC");
end

