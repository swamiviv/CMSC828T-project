function dist = plotDist(dirName)

if(exist(strcat(dirName,'\depthMetaData.mat')) > 0)
    data=load(strcat(dirName,'\depthMetaData.mat'));
else
    data=load(strcat(dirName,'\depthMetaDataClean.mat'));
end
fname = fieldnames(data);
depthMetaData = getfield(data,fname{1});
numFrames = length([depthMetaData.FrameNumber]);
%depthMetaDataClean = struct(depthMetaData);
numPeople = 2;
dist = [];
for i = 1:numFrames
    posTracked = depthMetaData(i).IsPositionTracked;
    skelTracked = depthMetaData(i).IsSkeletonTracked;
    
    if(sum(skelTracked) == 2)
        validIds = find(skelTracked == 1);
        jointData = depthMetaData(i).JointWorldCoordinates;
        hipjointPos1 = jointData(1,:,validIds(1));
        hipjointPos2 = jointData(1,:,validIds(2));   
        
        headjointPos1 = jointData(4,:,validIds(1));
        headjointPos2 = jointData(4,:,validIds(2)); 
        
        centroid1 = 0.5*(hipjointPos1+headjointPos1);
        centroid2 = 0.5*(hipjointPos2+headjointPos2);
        dist = [dist norm(centroid1-centroid2)];
    else
        dist = [dist 0];
    end
end
clear depthMetaData;
%plot(dist);
        
