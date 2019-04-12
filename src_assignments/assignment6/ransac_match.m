%  Apply normalized 8-point RANSAC algorithm to find best matches
% Input:
%     -directory: where to load images
% Output:
%     -C: coordinates of interest points
%     -D: descriptors of interest points
%     -Matches:Matches (between each two consecutive pairs, including the last & first pair)

function [C, D, Matches] = ransac_match(directory)
    Files=dir(strcat(directory, '*.png'));
    n = length(Files);

    % Initialize coordinates C and descriptors D
    C ={};
    D ={};
    % Load all features (coordinates and descriptors of interest points)
    % As an example, we concatenate the haraff and hesaff sift features
    % You can also use features extracted from your own Harris function.
    for i=1:n
        name = Files(i).name;
        disp(strcat("Loading features: ", name))
        disp(strcat("Loading progress %: ", num2str( (i / n) * 100)));
        
        [coord_haraff,desc_haraff,~,~] = loadFeatures(strcat(directory, name, '.haraff.sift'));
        [coord_hesaff,desc_hesaff,~,~] = loadFeatures(strcat(directory, name, '.hesaff.sift'));
        
        coord= [coord_haraff coord_hesaff];
        desc = [desc_haraff desc_hesaff];
        
        C{i} = coord(1:2, :);
        D{i} = desc;
    end

    % Initialize Matches (between each two consecutive pairs)
    Matches={};

    for i=1:n

        % Next image - take image 1 for the last image
        next = i+1;        
        if next > n
            next = 1;
        end
        
        coord1 = C{i};
        desc1  = D{i};
        
        coord2 = C{next};
        desc2  = D{next};
        
        disp('Matching Descriptors');drawnow('update')
        % Find matches according to extracted descriptors using vl_ubcmatch
        [match, ~] = vl_ubcmatch(desc1,desc2);
        disp(strcat( int2str(size(match,2)), ' matches found'));drawnow('update')
        
        % Obtain X,Y coordinates of matches points
        match1 = coord1(1:2,match(1,:));
        match2 = coord2(1:2,match(2,:));
        
        % Find inliers using normalized 8-point RANSAC algorithm
        [~, inliers] = estimateFundamentalMatrix(match1,match2);
        drawnow('update')
        Matches{i} = match(:,inliers);
        
        disp(strcat("Matching progress %: ", num2str( (i / n) * 100)));
        
    end

end
