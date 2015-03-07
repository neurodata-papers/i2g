%% MICCAI 2014 SCAFFOLD
% W. Gray Roncal
% Copyright 2013, All Rights Reserved.

% scaffold_error_metrics.m is the main function to run the various portions of code
% stringrpLabelOut = regionprops(labelOut,'Area','PixelIdxList');
% NOTE THAT THIS BREAKS COMPATIBILITY WITH EARLIER VERSIONS OF THE CODE

function errMetrics = segErrorMetrics(labelTest, labelTruth)
%errorForce = 1;
thresh = 500;

% This allows either RAMONVolumes or matrices to be used
if isa(labelTest,'RAMONVolume')
    labelTest = labelTest.data;
    disp('label test data extracted from RAMONVolume')
else
    disp('label test data assumed to be in matrix form.')
end

if isa(labelTruth,'RAMONVolume')
    labelTruth = labelTruth.data;
    disp('label truth data extracted from RAMONVolume')
else
    disp('label truth data assumed to be in matrix form')
end

if sum(labelTest(:,:,1)) == 0
    error('Volume appears to be blank - please check and try again.')
end

%labelTruth, labelTest
rp3d = regionprops(labelTruth,'PixelIdxList','Area','PixelList');

labelTest = relabel_id(labelTest);
for i = 1:length(rp3d)
    tt = unique(labelTest(rp3d(i).PixelIdxList));
    tt(tt==0) = [];
    splitErr(i) = max(0,length(tt)-1);%unique(labelOut(rp3d(i).PixelIdxList)))-1;
    if length(tt) < 2
        splitErrThresh(i) = max(0, length(tt)-1);
    else
        h =  hist(labelTest(rp3d(i).PixelIdxList),double(tt));
        splitErrThresh(i) = max(0,sum(h > thresh)-1);
    end
end

%errMetrics.totalSplits  = sum(splitErr);
errMetrics.averageSplits = sum(splitErr)/length(rp3d);
errMetrics.splitErrThreshAvg = sum(splitErrThresh)/length(rp3d);
errMetrics.splitErrThreshSum = sum(splitErrThresh);
errMetrics.splitErr = splitErr;
errMetrics.splitErrThresh = splitErrThresh;

rpLabelOut = regionprops(labelTest,'Area','PixelIdxList');

count = 1;
for i = 1:length(rpLabelOut)
    
    if rpLabelOut(i).Area > 0
        objVal = labelTruth(rpLabelOut(i).PixelIdxList);
        mergeErr(count) = length(unique(objVal))-1;
        if length(unique(objVal)) < 2
            mergeErrThresh(i) = length(unique(objVal))-1;
        else
            h =  hist(objVal,double(unique(objVal)));
            mergeErrThresh(i) = max(0,sum(h > thresh)-1);
        end
        count = count + 1;
    end
end

errMetrics.totalMerges  = sum(mergeErr);
errMetrics.averageMerges = sum(mergeErr)/length(rpLabelOut); %TODO Confirm
errMetrics.mergeErrThresh = mergeErrThresh;
errMetrics.mergeErrThreshAvg = sum(mergeErrThresh)/length(rpLabelOut);
errMetrics.mergeErrThreshSum = sum(mergeErrThresh);
errMetrics.mergeErr = mergeErr;
clear rp3d
[errMetrics.challErr, p_ij] = SNEMI3D_metrics(labelTruth,labelTest);

errMetrics