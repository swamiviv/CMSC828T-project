function playAction( folder,frames )
%PLAYSKELETON Summary of this function goes here
%   Detailed explanation goes here

    listing = dir([folder '/*.jpg']);
       
    if(exist(strcat(folder,'/depthMetaData.mat')) > 0)
         data = load( [folder '/depthMetaData.mat' ]);
    else
        data = load( [folder '/depthMetaData.mat' ]);
    end

    fname = fieldnames(data);
    depthMetaData = getfield(data,fname{1});
   
    for i=1:length(frames)
     
        trackedSkeletons = find(depthMetaData(frames(i)).IsSkeletonTracked);
        nSkeleton = length(trackedSkeletons);
        framenum = frames(i)
        
        if nSkeleton >= 1 
            jointIndices = depthMetaData(i).JointImageIndices(:, :, trackedSkeletons);
            name = [folder '/' listing(framenum).name];
            image = imread( name );
            %util_skeletonViewer(jointIndices, image, nSkeleton);
            imshow(image);
            pause(0.1);
            
            
        end
    end
end

