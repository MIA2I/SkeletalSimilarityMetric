close all
clear all
clc
warning off;

SrcVessels = imread('./Data/01_manual2.gif');
RefVessels = imread('./Data/01_manual1.gif');
Mask = imread('./Data/01_test_mask.gif');

% Skeletal similarity for r-Se, r-Sp and r-Acc
[ rSe, rSp, rAcc, SS, Confidence ] = SkeletalSimilarity( SrcVessels, RefVessels, Mask );

% Traditional Se, Sp and Acc
[ Se, Sp, Precision, F1, G, MCC, Acc ] = Accuracy( SrcVessels, RefVessels, Mask);

% Didplay results
result=sprintf('Se = %.6g, Sp = %.6g, Acc = %.6g, rSe = %.6g, rSp = %.6g, rAcc = %.6g.\r\n', Se, Sp, Acc, rSe, rSp, rAcc);
disp(result);
