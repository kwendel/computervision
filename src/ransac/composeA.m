% function A = composeA(x1, x2)
% Compose matrix A, given matched points (X1,X2) from two images
% Input: 
%   -normalized points: X1 and X2 
% Output: 
%   -matrix A
function A = composeA(x1, x2)

    % We assume that x1 and x2 have the same size, as they are matches
    % Get x,y coords of the match
    x = x1(1,:)';
    y = x1(2,:)';
    x_m = x2(1,:)';
    y_m = x2(2,:)';

    % Fill A matrix according to eq. 2
    A = [x .* x_m, x.*y_m, x, y.*x_m, y.*y_m, y, x_m, y_m, ones(length(x1),1)];
end
