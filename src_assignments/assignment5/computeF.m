% function F = computeF(A,T1,T2)
% Compute and denormalize F 
% Input: 
%   -matrix A, normalization matrix T1 and T2
% Output: 
%   -Fundameantal matrix F
function F = computeF(A,T1,T2)

    % Solution for Af=0 using SVD
    [~,~,V] = svd(A);
    f = V(:,end);
    % To reshape row wise, we take the transpose
%     F = reshape(f,[3 3])';
    F = reshape(f,3,3);

    % Resolve the rank 2 constraint: det(F) =0 using SVD
    % The lowest eigenvalue is at (3,3) as S is ordered decreasingly
    [U,S,V] = svd(F);
    S(3,3) = 0;
    F = U*S*V';

    % De-normalize F
    % F= T'_2 F T_1
    F = T2' * F * T1;

    % One more step: make sure that the norm of output_F is 1 (To deal with the scale invariance)
    F= F/norm(F);
end
