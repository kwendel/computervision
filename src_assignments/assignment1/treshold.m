function I = treshold(img,treshold)
%TRESHOLD Makes the picture binary according to the treshold value: below
%will be 0/black and above or equal will be 1/white

idx = find(img >= treshold);
I = zeros(size(img));
I(idx) = 1;
end

