function feature = extractFeatures( matfilePath )
%PLAYSKELETON Summary of this function goes here
%   Detailed explanation goes here
    
    % input: mat file
    % extract skeleton features only when two people are tracked at each
    % frame

    addpath('quaternions');
    load( matfilePath );
        
    count = 1;
    for i=1:length(depthMetaData)
        
        if sum( depthMetaData(i).IsSkeletonTracked ) == 2 % If two people are tracked
            
            fprintf('frame = %d\n', depthMetaData(i).FrameNumber');
            
            twoPeopleJointCoordinates = depthMetaData(i).JointWorldCoordinates(:,:,depthMetaData(i).IsSkeletonTracked);
            
            [jointLocalCoordinatesFirstPerson, jointLocalCoordinatesSecondPerson] = calcJointPersonCoordinates( twoPeopleJointCoordinates, 1 );
            
            sticksFirstPerson = calcSticks( jointLocalCoordinatesFirstPerson );
            sticksSecondPerson = calcSticks( jointLocalCoordinatesSecondPerson );
            
            feat1 = calcRelativeGeometry( [sticksFirstPerson sticksSecondPerson] );
            
            [jointLocalCoordinatesFirstPerson, jointLocalCoordinatesSecondPerson] = calcJointPersonCoordinates( twoPeopleJointCoordinates, 2 );
            
            sticksFirstPerson = calcSticks( jointLocalCoordinatesFirstPerson );
            sticksSecondPerson = calcSticks( jointLocalCoordinatesSecondPerson );
            
            feat2 = calcRelativeGeometry( [sticksFirstPerson sticksSecondPerson] );
            
            feature(count,:) = [feat1 feat2];
            
            count = count + 1;
        end
    end
    
end

