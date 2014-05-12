function x = bit2ndx(xb,n,word)
%
% xb = compacted string of bits
% n = number of bits used to code each element of 'x'
%
% x = unit8 array

if nargin<3
    word = 32;
end

[nw nSamples] = size(xb);

% number of indices
dim = length(n);

x = zeros([dim nSamples], 'uint8');

m = 0;
w = 1;
for j = 1:dim
    n(j);
    for i = 1:n(j)
        m = m+1;
        c = bitget(xb(w,:), m);
        x(j,:) = bitset(x(j,:), i, c);
        
        if m == word
            w = w+1;
            m = 0;
        end
    end
end


