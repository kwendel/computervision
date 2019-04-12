% Ransac implementation to find the affine transformation between two images.
% Input:
%       match1 - set of point from image 1
%       match2 - set of corresponding points from image 2
%       im1    - the first image
%       im2    - the second image
% Output:
%       best_h - the affine affine transformation matrix

function best_h = ransac_affine(match1, match2, im1, im2)
    % Iterations is automatically changed during runtime
    % based on inlier-count. Set min-iterations (e.g. 5 iterations) to circumvent corner-cases
    iterations = 50;
    miniterations = 5;

    % Threshold: the 10 pixels radius
    threshold = 10;

    % The model needs at least 3 point pairs (3 equations) to form an affine transformation
    % (6 unknows)
    P = 3;

    % Start the RANSAC loop
    bestinliers = 0;
    best_h      = zeros(6,1);

    it=1;
    while ((it<iterations) || (it<miniterations))
        % (1) Pick randomly P matches
        perm = randperm(length(match1));
        seed = perm(1:P);

        % (2) Construct matrices A, h, b 
        A = zeros(2*P, 6);
        h = zeros(6,1);
        b = zeros(2*P,1);
        
        for i = 1:length(seed)
            m1 = match1(:,seed(i));
            m2 = match2(:,seed(i));
            
            idx = 2*i;
            
            A(idx-1,:) = [m1(1) m1(2) 0 0 1 0];
            A(idx,:) = [0 0 m1(1) m1(2) 0 1];
            
            b(idx-1) = m2(1);
            b(idx) = m2(2);
        end
        
        % (3) Fit model h over the matches
        h = pinv(A) * b;
%         h = linsolve(A,b);

        % (4) Transform all points from image1 to their counterpart in image2. Plot these correspondences.
%         figure; imshow([im1 im2]); hold on;
        
        % Construct A matrix for all the points of match1
        A_all = zeros(2*length(match1), 6);
        for i = 1:length(match1)
            pt = match1(:,i);
            idx = 2*i;
            A_all(idx - 1,:) = [pt(1) pt(2) 0 0 1 0];
            A_all(idx,:) = [0 0 pt(1) pt(2) 0 1];
        end
        
        bprim = A_all * h;
        match1t = reshape(bprim',[2, length(bprim)/2]);
        
%         line([match1(1,seed); size(im1,2)+match1t(1,seed)],...
%              [match1(2,seed);             match1t(2,seed)]);
%         title('Image 1 and 2 with the original points and their transformed counterparts in image 2');
    
        % (5) Determine inliers using the threshold and save the best model
        inliers = length(find(sqrt(sum((match2 - match1t) .^2)) < threshold));

        % (6) Save the best model and redefine the stopping iterations
        if bestinliers < inliers
            bestinliers = inliers;
            best_h = h;
        end  

        % Compute amount of iterations
        % err = (1-q^P)^i 
        q = bestinliers / size(match1,2);
        iterations = log(0.001) / log(1-q^P);

        it = it+1;
    end
end
