close all
clear all
clc
warning off;

% Input vessel segmentation maps: 
% Guarantee: "1" represents vessel pixel and "0" denotes non-vessel pixel
SrcVessels = uint8(imread('./Data/STARE/im0163_manual2.png'));
SrcVessels(SrcVessels>0) = 1;
% SrcVessels = 1 - SrcVessels;
RefVessels = imread('./Data/STARE/im0163_manual1.png');
RefVessels(RefVessels>0) = 1;
% RefVessels = 1 - RefVessels;

Mask = imread('./Data/STARE/im0163_mask.png');

% Hyperparameter
R = 2;
Alpha = 0.2;

% Traditional Se, Sp and Acc
[ Se, Sp, Precision, F1, G, MCC, Acc ] = Accuracy( SrcVessels, RefVessels, Mask);
% Didplay results
result=sprintf('Se = %.3g, Sp = %.3g, Acc = %.3g.', Se/100.0, Sp/100.0, Acc/100.0);
disp(result);

% CAL function
f = CAL(SrcVessels, RefVessels, 2, 2);
% Didplay results
result=sprintf('CAL = %.3g.', f);
disp(result);

% Skeletal similarity for r-Se, r-Sp and r-Acc
[ rSe, rSp, rAcc, SS, Confidence, SearchingMask ] = SkeletalSimilarity( SrcVessels, RefVessels, Mask, Alpha, R );
% Didplay results
result=sprintf('Confidence = %.3g, rSe = %.3g, rSp = %.3g, rAcc = %.3g.', Confidence, rSe/100.0, rSp/100.0, rAcc/100.0);
disp(result);

%     % Rnc for centerline detection
%     SrcSkeleton = uint8(bwmorph(SrcVessels,'thin',inf));
%     RefSkeleton = uint8(bwmorph(RefVessels,'thin',inf));
%     Rnc = sum(sum(SrcSkeleton-SearchingMask.*SrcSkeleton)) * 1.0 / sum(sum(RefSkeleton));
%     % Didplay results
%     result=sprintf('Rnc = %.3g.', Rnc);
%     disp(result);