function [C, D] = harris_features(directory, all_files, n_files, scale, tf)
%LOAD_FEATURES Loads all of the feature set
%   
print_start("loading features")

% Check if coordinates and descriptors were already computed
if exist(strcat(directory, 'C_harris.mat')) && exist(strcat(directory, 'D_harris.mat'))
    load(strcat(directory, 'C_harris.mat'));
    load(strcat(directory, 'D_harris.mat'));
    
    disp("C_harris & D_harris were loaded from C_harris.mat & D_harris.mat");
    print_end("Finding Harris features")
    return
end

% Initialize coordinates C and descriptors D
C = {};
D = {};
% Load all features (coordinates and descriptors of interest points)
% Each feature is a combination of the haraff and hesaff sift features
for i=1:n_files
    name = all_files(i).name;

	im = im2double( rgb2gray( imread(strcat(directory, name) ) ) );
	imresized = imresize(im, scale);
	loc = DoG_final(imresized, tf);
	[r, c, sigma] = harris_final(imresized, loc);
	orient = zeros(size(sigma));
	fc = [c'; r'; sigma'; orient' ];
	[coord, desc] = vl_sift(single(imresized), 'frames', fc) ;
	
	C{i} = coord(1:2, :);
	D{i} = desc;
	
% 	figure
% 	imshow(imresized,[]);
% 	hold on

% 	vl_plotsiftdescriptor(desc,coord) ;
% 	vl_plotframe(coord);
	
    print_progress("Found Harris features: ", (i/n_files) , name);
end


% Save the coordinates and descriptors
save(strcat(directory, 'C_harris.mat'), 'C');
save(strcat(directory, 'D_harris.mat'), 'D');

print_end(": Saved Harris features")

end