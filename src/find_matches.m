function [Matches] = find_matches(directory, C, D, n_files, harris_scale, Harris_on, vlthresh)
%MATCH Match the given coordinates and their descriptors using the 8 points
% RANSAC algorithm
	print_start("matching with RANSAC");

	if Harris_on == 1
		if exist(strcat(directory, 'Matches_harris.mat'))
			load(strcat(directory, 'Matches_harris.mat'));
			disp("Matches were loaded from Matches_harris.mat");
			print_end("matching Harris features with RANSAC");
			return
		end
	else
		% Check if matches were already computed
		if exist(strcat(directory, 'Matches.mat'))
			load(strcat(directory, 'Matches.mat'));
			disp("Matches were loaded from Matches.mat");
			print_end("matching with RANSAC");
			return
		end
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
		[match, ~] = vl_ubcmatch(desc1, desc2, vlthresh);
		disp(strcat( int2str(size(match,2)), ' matches found'));

		% Obtain X,Y coordinates of matches points
		match1 = coord1(1:2,match(1,:));
		match2 = coord2(1:2,match(2,:));

		% Find inliers using normalized 8-point RANSAC algorithm
		threshold = 10;
		[~, inliers] = estimateFundamentalMatrix(match1, match2, threshold);
		Matches{i} = match(:,inliers);
		
        % Plot matches with Harris
% 		if Harris_on == 1
% 			% Show all matched features between pair of images
% 			idx1in = match(1,inliers);
% 			idx2in = match(2,inliers);
% 			name1 = all_files(i).name;
% 			name2 = all_files(next).name;
% 			img1 = imresize( im2double( rgb2gray( imread(strcat(directory, name1) ) ) ), harris_scale );
% 			img2 = imresize( im2double( rgb2gray( imread(strcat(directory, name2) ) ) ), harris_scale );
% 
% 			figure;
% 			imshow([img1,img2],'InitialMagnification', 'fit');
% 			title('Images with matched points'); hold on;
% 
% 			scatter(coord1(1,idx1in), coord1(2,idx1in), 'y'); % x and y coordinates for 1st image
% 
% 			scatter(size(img1,2)+ coord2(1,idx2in), coord2(2,idx2in) ,'r'); % x and y coordinates for 2nd image
% 			% draw lines from [x_img1;x_img2] to [y_img1;y_img2]
% 			line([coord1(1,idx1in);size(img1,2)+coord2(1,idx2in)], [coord1(2,idx1in);coord2(2,idx2in)], 'Color', 'b');
% 
% 			% search for outliers
% 			outliers = setdiff(1:size(match,2), inliers);
% 			idx1out = match(1,outliers);
% 			idx2out = match(2,outliers);
% 			% draw lines from [x_img1;x_img2] to [y_img1;y_img2]
% 			line([coord1(1,idx1out);size(img1,2)+coord2(1,idx2out)], [coord1(2,idx1out);coord2(2,idx2out)], 'Color', 'r');
% 		end
		
		print_progress("Matched file: ", (i / n_files), num2str(i));
	end
	
	if Harris_on == 1
		% Save the matches 
		save(strcat(directory, 'Matches_harris.mat'), 'Matches');
		print_end("matching Harris features with RANSAC");
	
	else
		% Save the matches 
		save(strcat(directory, 'Matches.mat'), 'Matches');
		print_end("matching with RANSAC");
	end
end

