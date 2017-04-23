function [ rSe, rSp, rAcc, SS, Confidence ] = SkeletalSimilarity( SrcVessels, RefVessels )
%SKELETALSIMILARITY Summary of this function goes here
%   Detailed explanation goes here
%Hyperparameters
Levels = 3;
minLength = 8;
avgLength = 15;
%Initialization
[height, width] = size(RefVessels);
SrcVessels(SrcVessels>0) = 1;
SrcSkeleton = bwmorph(SrcVessels,'thin',inf);
RefVessels(RefVessels>0) = 1;
RefSkeleton = bwmorph(RefVessels,'thin',inf);

% Generate the searching range of each pixel
[ Thickness, minRadius, maxRadius ] = CalcThickness( RefSkeleton, RefVessels);
bin = floor(maxRadius - minRadius) / Levels;
SearchingRadius = 2 * ones(height, width, 'uint8');
SearchingRadius(Thickness<bin+minRadius) = 3;
SearchingRadius(Thickness>2*bin+minRadius) = 1;
SearchingRadius(RefSkeleton==0) = 0;
SearchingMask = GenerateRange(SearchingRadius);
% Delete wrong skeleton segments
SrcSkeleton(SearchingMask==0) = 0;

% Segment the target skeleton map
[ SegmentID ] = SegmentSkeleton( RefSkeleton, minLength, avgLength );

% Calculate the confidence
OriginalSkeleton = RefSkeleton;
EvaluationSkeleton = SegmentID;
EvaluationSkeleton(EvaluationSkeleton>0) = 1;
Confidence = sum(sum(EvaluationSkeleton)) *1.0 / sum(sum(OriginalSkeleton));

% Calculate the skeletal similarity for each segment
SS = 0.0;
for Index = 1:max(max(SegmentID))
    
    SegmentRadius = SearchingRadius;
    SegmentRadius(SegmentID~=Index) = 0;
    SegmentMask = GenerateRange(SegmentRadius);
    SrcSegment = SrcSkeleton;
    SrcSegment(SegmentMask==0)=0;
    
    % Remove additionally seleted pixels
    SrcSegment = NoiseRemoval(SrcSegment, RefSkeleton, SegmentID, Index);
    [SrcX, SrcY] = find(SrcSegment>0);
    [RefX, RefY] = find(SegmentID==Index);
    
    if (length(unique(SrcX)) > length(unique(SrcY)))
        SS = SS + CalcSimilarity(SrcX, SrcY, RefX, RefY) * length(RefX);
    else
        SS = SS + CalcSimilarity(SrcY, SrcX, RefY, RefX) * length(RefX);
    end
    
end

SegmentID(SegmentID>0) = 1;
SS = SS / sum(sum(SegmentID));
PositiveMask = SearchingMask + RefVessels;
PositiveMask(PositiveMask>0) = 1;
TP = SS * sum(sum(PositiveMask));
FN = (1 - SS) * sum(sum(PositiveMask));
FP = sum(sum(SrcVessels.*(1-PositiveMask)));
TN = sum(sum((1-SrcVessels).*(1-PositiveMask)));
rSe = TP * 100.0 / (TP + FN);
rSp = TN * 100.0 / (TN + FP);
rAcc = (TP + TN) * 100 / (TP + FN +TN + FP);

function [ Score ] = CalcSimilarity(SrcX, SrcY, RefX, RefY)

Score = 0.0;

Temp = []; Temp(1) = RefX(1);
index = 2;
while(index<=length(RefX))
    if ismember(RefX(index), Temp)
        RefX(index) = RefX(index) + 0.01;
        continue;
    else
        Temp(index) = RefX(index);
    end
    index = index + 1;
end
RefPolyComplete = fit(RefX, RefY, 'poly3');
RefPoly = [RefPolyComplete.p1, RefPolyComplete.p2, RefPolyComplete.p3];


if (length(SrcX) > 0.6 * length(RefX))
    Temp = []; Temp(1) = SrcX(1);
    index = 2;
    while(index<=length(SrcX))
        if ismember(SrcX(index), Temp)
            SrcX(index) = SrcX(index) + 0.01;
            continue;
        else
            Temp(index) = SrcX(index);
        end
        index = index + 1;
    end
    SrcPolyComplete = fit(SrcX, SrcY, 'poly3');
    SrcPoly = [SrcPolyComplete.p1, SrcPolyComplete.p2, SrcPolyComplete.p3];
    
    Score = abs(dot(SrcPoly, RefPoly) / (norm(SrcPoly) + 1e-10) / norm(RefPoly + 1e-10));
    
end

function [ UpdatedSegment ] = NoiseRemoval(SrcSegment, RefSkeleton, SegmentID, ID)
[height, width] = size(SegmentID);
UpdatedSegment = SrcSegment;
[X, Y] = find(SrcSegment>0);
for Index = 1:length(X)
    minRadius = 10;
    minID = 0;
    if (SegmentID(X(Index),Y(Index))>0)
        if (SegmentID(X(Index),Y(Index))~=ID)
            UpdatedSegment(X(Index),Y(Index)) = 0;
        end
        continue;
    else
        for x = max(X(Index)-5, 1):min(X(Index)+5, height)
            for y = max(Y(Index)-5, 1):min(Y(Index)+5, width)
                if ((x==X(Index)) && (y==Y(Index)))
                    continue;       
                end
                if (RefSkeleton(x,y)>0)
                    if ((sqrt((x-X(Index))^2+(y-Y(Index))^2)<minRadius) || ((sqrt((x-X(Index))^2+(y-Y(Index))^2)==minRadius) && (SegmentID(x,y)==ID)))
                        minID=SegmentID(x,y);
                        minRadius = sqrt((x-X(Index))^2+(y-Y(Index))^2);
                    end
                end
            end
        end
    end
    if (minID~=ID)
        UpdatedSegment(X(Index),Y(Index)) = 0;
    end
end
