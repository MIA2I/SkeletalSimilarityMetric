function [ Se, Sp, Precision, F1, G, MCC, Acc ] = Accuracy( predLabel, Label, mask)
%ACCURACY Summary of this function goes here
%   Detailed explanation goes here

TP = 0;
FN = 0;
TN = 0;
FP = 0;
Total = 0;

[height, width, rim] = size(predLabel);

for i = 1: height
    for j= 1: width
        if(mask(i,j) > 0)
            if ((predLabel(i,j) == 0) && (Label(i,j) == 0))
                TN = TN +1;
            end
            if ((predLabel(i,j) == 1) && (Label(i,j) == 0))
                FP = FP +1;
            end
            if ((predLabel(i,j) == 1) && (Label(i,j) == 1))
                TP = TP +1;
            end
            if ((predLabel(i,j) == 0) && (Label(i,j) == 1))
                FN = FN +1;
            end
            Total = Total + 1;
        end
    end
end

N = TP + TN + FP + FN;

if (N == Total)
    display('True!');
end

S = double(TP + FN) / double(N);
P = double(TP + FP) / double(N);
Se = TP * 100.0 / (TP + FN);
Sp = TN * 100.0 / (TN + FP);
Precision = TP * 100.0 / (TP + FP);
F1 = 2.0 * Precision * Se / (Precision + Se);
G = sqrt(Se * Sp);
MCC = (TP / N - S * P) * 100 / sqrt(P * S * (1-S) * (1-P));
Acc = (TP + TN) * 100 / (TP + FN +TN + FP);
