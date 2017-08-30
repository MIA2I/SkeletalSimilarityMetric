function [ f ] = CAL( SrcVessels, RefVessels, alpha, beta )
%CAL Summary of this function goes here
%   Detailed explanation goes here

% Initialization
SrcVessels(SrcVessels>0) = 1;
RefVessels(RefVessels>0) = 1;

% Calculation of C
[Lref, Cref] = bwlabel(RefVessels, 8);
[Lsrc, Csrc] = bwlabel(SrcVessels, 8);
C = 1 - min(1, abs(Cref-Csrc)/sum(sum(RefVessels)));

% Calculation of A
SE = strel('disk', alpha);
dilatedRefAlpha = imdilate(RefVessels,SE);
dilatedSrcAlpha = imdilate(SrcVessels,SE);
dilateOverlap = dilatedSrcAlpha .* RefVessels + dilatedRefAlpha .* SrcVessels;
dilateOverlap(dilateOverlap>0) = 1;
Overlap = RefVessels + SrcVessels;
Overlap(Overlap>0) = 1;
A = sum(sum(dilateOverlap)) / sum(sum(Overlap));

% Calculation of L
SrcSkeleton = uint8(bwmorph(SrcVessels,'thin',inf));
RefSkeleton = uint8(bwmorph(RefVessels,'thin',inf));

SE = strel('disk', beta);
dilatedRefBeta = imdilate(RefVessels,SE);
dilatedSrcBeta = imdilate(SrcVessels,SE);

dilateSkelOverlap = SrcSkeleton .* dilatedRefBeta + RefSkeleton .* dilatedSrcBeta;
dilateSkelOverlap(dilateSkelOverlap>0) = 1;
SkelOverlap = SrcSkeleton + RefSkeleton;
SkelOverlap(SkelOverlap>0) = 1;
L = sum(sum(dilateSkelOverlap)) / sum(sum(SkelOverlap));

% Score of the CAL function
f = C * A * L;

end

