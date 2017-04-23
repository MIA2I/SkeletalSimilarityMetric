function [SearchingMask] = GenerateRange( SearchingRadius )
%CALCDIRECTION Summary of this function goes here
%   Detailed explanation goes here
[height, width] = size(SearchingRadius);
SearchingMask = zeros(height, width, 'uint8');
for x = 1:height
    for y = 1:width
        if( SearchingRadius(x, y) > 0 )
            
            top = max(x - 10, 1);
            bottom = min(x + 10, height);
            left = max(y - 10, 1);
            right = min(y + 10, width);
            
            for i = top:bottom
                for j = left:right
                    if (floor(sqrt(double((i - x)^2 + (j - y)^2))) <= SearchingRadius(x,y))
                        SearchingMask(i,j) = 1;
                    end
                end
            end
            
        end
    end
end