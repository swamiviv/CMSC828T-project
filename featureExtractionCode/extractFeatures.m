function feature = extractFeatures( path_to_video )
%PLAYSKELETON Summary of this function goes here
%   Detailed explanation goes here
    
    % input: mat file
    % extract skeleton features only when two people are tracked at each
    % frame

    addpath('quaternions');
    
    if(exist([path_to_video '/depthMetaData.mat']) > 0)
        load([path_to_video '/depthMetaData.mat']);
    else
        load([path_to_video '/depthMetaDataClean.mat']);
        depthMetaData = depthMetaDataClean;
    end
        
    [startFrame,endFrame] = findactionshot(path_to_video);
    
    count = 1;
    for i=1:length(depthMetaData)
        
        if depthMetaData(i).FrameNumber < startFrame || depthMetaData(i).FrameNumber > endFrame
            continue;
        end
        
        if sum( depthMetaData(i).IsSkeletonTracked ) == 2 % If two people are tracked
            
            %fprintf('frame = %d\n', depthMetaData(i).FrameNumber');
            err1 = 0;
            err2 = 0;
            
            twoPeopleJointCoordinates = depthMetaData(i).JointWorldCoordinates(:,:,depthMetaData(i).IsSkeletonTracked);
            
            [jointLocalCoordinatesFirstPerson, jointLocalCoordinatesSecondPerson] = calcJointPersonCoordinates( twoPeopleJointCoordinates, 1 );
            
            sticksFirstPerson = calcSticks( jointLocalCoordinatesFirstPerson );
            sticksSecondPerson = calcSticks( jointLocalCoordinatesSecondPerson );
            
            try
            feat1 = calcRelativeGeometry( [sticksFirstPerson sticksSecondPerson] );
            catch
               err1=1; 
            end
            
            [jointLocalCoordinatesFirstPerson, jointLocalCoordinatesSecondPerson] = calcJointPersonCoordinates( twoPeopleJointCoordinates, 2 );
            
            sticksFirstPerson = calcSticks( jointLocalCoordinatesFirstPerson );
            sticksSecondPerson = calcSticks( jointLocalCoordinatesSecondPerson );
            
            try
            feat2 = calcRelativeGeometry( [sticksFirstPerson sticksSecondPerson] );
            catch
                err2=1;
            end
            
            if err1==0 && err2 == 0
                feature(count,:) = [feat1 feat2];
                count = count + 1;
            end
        end
    end
    
end

