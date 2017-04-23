close all
clear all
clc
warning off;

% Read data
SrcVessels = imread('./Data/01_manual2.gif');
RefVessels = imread('./Data/01_manual1.gif');
mask = imread('./Data/01_test_mask.gif');
% Skeletal similarity for r-Se, r-Sp and r-Acc
[ rSe, rSp, rAcc, SS, Confidence ] = SkeletalSimilarity( SrcVessels, RefVessels );
% Traditional Se, Sp and Acc
[ Se, Sp, Precision, F1, G, MCC, Acc ] = Accuracy( SrcVessels, RefVessels, mask);