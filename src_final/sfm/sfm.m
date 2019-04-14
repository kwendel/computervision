% Structure from Motion that shows the 3D structure of the points in the space. 
% 
% INPUT
%   Set of point correspondences to be read from local file. 
%
% OUTPUT
%   Optional: An image showing the 3D points in their estimated 3D world position.
%   M: The transformation matrix size of 2nx3. Where n is the number of cameras i.e. images.
%   S: The estimated 3-dimensional locations of the points (3x#points).

function [M,S,p] = sfm(X)
    % Centering: subtract the centroid of the image points (removes translation)
    for j = 1:size(X,1)
        X(j,:) = X(j,:) - mean(X(j,:));
    end

    % Singular value decomposition
    % Remark: Please pay attention to using V or V'. Please check matlab function: "help svd".
    [U,S,V] = svd(X);

    % The matrix of measurements must have rank 3.
    % Keep only the corresponding top 3 rows/columns from the SVD decompositions.
    U = U(:,1:3);
    W = S(1:3,1:3);
    V = V(:,1:3);

    % Compute M and S: One possible decomposition is M = U W^{1/2} and S = W^{1/2} V'
    M = U * sqrt(W);
    S = sqrt(W) * V';
    
    % Eliminate the affine ambiguity
    % Orthographic: We need to impose that image axes (a1 and a2) are perpendicular and their scale is 1.
    % (a1: col vector, projection of x; a2: row vector, projection of y;,)
    % We define the starting value for L, L0 as: A1 L0 A1' = Id 
    A1 = M(1:2, :);
    L0 = pinv(A1' * A1);

    % We solve L by iterating through all images and finding L one which minimizes Ai*L*Ai' = Id, for all i.
    % LSQNONLIN solves non-linear least squares problems. Please check the Matlab documentation.
    options = optimoptions(@lsqnonlin, 'Display', 'off');
    L = lsqnonlin(@(x)residuals(x,M), L0,[],[],options);

    % Recover C from L by Cholesky decomposition.
    [C,p] = chol(L,'lower');
    
    % Factorization was succesfull, perform multiplication
    if p == 0
        % Update M and S with the corresponding C form: M = MC and S = C^{-1}S. 
        M = M*C;
        S = pinv(C) * S;
    end

    % Plot the obtained 3D coordinates:
%     X = S(1,:)';
%     Y = S(2,:)';
%     Z = S(3,:)';
%     figure;
%     scatter3(X, Y, Z, 20, [1 0 0], 'filled');
%     axis( [-500 500 -500 500 -500 500] )
%     daspect([1 1 1])
%     rotate3d on;
end
