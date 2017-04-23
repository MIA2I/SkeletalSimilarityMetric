function [ SegmentID ] = SegmentSkeleton( RefSkeleton, minLength, avgLength)
%SEGMENTSKELETON Summary of this function goes here
%   Detailed explanation goes here

% Removing intersecting pixels
[X, Y] = find(RefSkeleton>0);
for Index = 1:length(X)
    if (sum(sum(RefSkeleton(X(Index)-1:X(Index)+1, Y(Index)-1:Y(Index)+1)))>3)
        RefSkeleton(X(Index),Y(Index)) = 0;
    end
end

% Delete segments smaller than minLength
[L, num] = bwlabel(RefSkeleton, 8);
for Index = 1:num
   Component = RefSkeleton;
   Component(L~=Index) = 0;
   Component(Component>0) = 1;
   if (sum(sum(Component))<minLength)
       RefSkeleton(L==Index)=0;
   end
end
[L, num] = bwlabel(RefSkeleton, 8);
SegmentID = L;
% Cut segments longer than maxLength
for Index = 1:num
   Component = SegmentID;
   Component(Component~=Index) = 0;
   Component(Component>0) = 1;
   L = sum(sum(Component));
   if (L>avgLength)
       SegmentID(SegmentID==Index) = 0;
       UpdateSegmentID = CutSegment(Component, L, Index, max(max(SegmentID)), avgLength);
       SegmentID = SegmentID + UpdateSegmentID;
   end
end

function [ UpdateSegmentID ] = CutSegment(Segment, L, Index, ID, AvgLength)

UpdateSegmentID = Segment;
nums = floor(double(L)/AvgLength);
TarLength = round(double(L) / nums);
[X, Y] = find(Segment>0);
for index = 1:length(X)
    if(sum(sum(Segment(X(index)-1:X(index)+1, Y(index)-1:Y(index)+1)))==2)
        startX = X(index);
        startY = Y(index);
        break;
    end
end
IDs = zeros(length(X),1,'uint32');
SubLength = 1;
count = 1;
while(count<nums)
    IDs(index) = count;
    for index = 1:length(X)
        distance = sqrt((X(index)-startX)^2+(Y(index)-startY)^2);
        if((floor(distance)==1)&&(IDs(index)==0))
            startX = X(index);
            startY = Y(index);
            if(SubLength < TarLength)
                SubLength = SubLength + 1;
            else
                SubLength = 1;
                count = count + 1;
            end
            break;
        end
    end
end
for index = 1:length(X)
    if (IDs(index)>0)
        UpdateSegmentID(X(index), Y(index)) = IDs(index) + ID;
    else
        UpdateSegmentID(X(index), Y(index)) = Index;
    end
end