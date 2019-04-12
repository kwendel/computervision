% Function [Xout, T] = normalize( X )
% Normalize all the points in each image
% Input
%     -X: a matriX with 2D inhomogeneous X in each column.
% Output: 
%     -Xout: a matriX with (2+1)D homogeneous X in each column;
%     -matrix T: normalization matrix
function [Xout, T] = normalize( X )

    % Compute Xmean: normalize all X in each image to have 0-mean
    Xmean = X;
    for j = 1:size(X,1)
        Xmean(j,:) = X(j,:) - mean(X(j,:));
    end
    
    % Compute d: scale all X so that the average distance to the mean is sqrt(2).
    % Check the lab file for details.
    mx = mean(X(1,:));
    my = mean(X(2,:));
    n = size(X,2);
    d = (1 / n) * sum(sqrt( (Xmean(1,:) .^2) + (Xmean(2,:) .^2 )));
    % Compose matrix T
    sq = sqrt(2) / d;
    T = [   sq  0   -mx * sq    ;...
            0   sq  -my * sq    ;...
            0   0   1           ];
    
    % Compute Xout using X^ = TX with one extra dimension (We are using homogenous coordinates)
    Xout = T * [X; ones(1,size(X,2))];

end
