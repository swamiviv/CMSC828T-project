function [jointLocalCoordinatesFirstPerson, jointLocalCoordinatesSecondPerson] = calcJointPersonCoordinates( twoPeopleJointCoordinates, person )
%CALCJOINTPERSONCOORDINATES Summary of this function goes here
%   Detailed explanation goes here

    % input
    % twoPeopleJointCoordinates: 20 * 3  * 2 matrix
    
    if person == 1
        jointWorldCoordinatesFirstPerson = squeeze(twoPeopleJointCoordinates( :,:,1 ));
        jointWorldCoordinatesSecondPerson = squeeze(twoPeopleJointCoordinates( :,:,2 ));
    else
        jointWorldCoordinatesFirstPerson = squeeze(twoPeopleJointCoordinates( :,:,2 ));
        jointWorldCoordinatesSecondPerson = squeeze(twoPeopleJointCoordinates( :,:, 1 ));
    end
    
    center_shoulder = (jointWorldCoordinatesFirstPerson( 5, : ) + jointWorldCoordinatesFirstPerson( 9, : )) / 2;
    
    jointWorldCoordinatesFirstPerson = jointWorldCoordinatesFirstPerson - repmat( center_shoulder, 20, 1 ); % take offset
    jointWorldCoordinatesSecondPerson = jointWorldCoordinatesSecondPerson - repmat( center_shoulder, 20, 1 ); % take offset
    
    % compute rough rotation based on foot positions
    leftFootVec = jointWorldCoordinatesFirstPerson( 16, [1 3] ) - jointWorldCoordinatesFirstPerson( 15, [1 3] );
    rightFootVec = jointWorldCoordinatesFirstPerson( 20, [1 3] ) - jointWorldCoordinatesFirstPerson( 19, [1 3] );
    averageFootVec = (leftFootVec + rightFootVec )/ 2;
    footRotation = mod( atan2( averageFootVec(2), averageFootVec(1) ), 2*pi );
    
    % compute the first candidate of body rotation
    bodyRotation1 = atan2( jointWorldCoordinatesFirstPerson(5,3), jointWorldCoordinatesFirstPerson(5,1) );
    bodyRotation1 = mod( bodyRotation1 + pi/2, 2*pi);
    
    % compute the second candidate of body rotation
    bodyRotation2 = atan2( jointWorldCoordinatesFirstPerson(9,3), jointWorldCoordinatesFirstPerson(9,1) );
    bodyRotation2 = mod( bodyRotation2 + pi/2, 2*pi);
    
    % pick one closer to footRotation
    diff1 = min(  abs( bodyRotation1 - footRotation ), 2*pi - abs( bodyRotation1 - footRotation ) );
    diff2 = min(  abs( bodyRotation2 - footRotation ), 2*pi - abs( bodyRotation2 - footRotation ) );

    if diff1 < diff2 
        bodyRotation = bodyRotation1;
    else
        bodyRotation = bodyRotation2;
    end
    bodyRotation = bodyRotation + pi/2;
    rotmat = [cos(-bodyRotation) -sin(-bodyRotation) ; sin(-bodyRotation) cos(-bodyRotation)];
    
    jointLocalCoordinatesFirstPerson = jointWorldCoordinatesFirstPerson;
    jointLocalCoordinatesFirstPerson(:,[1 3]) = (rotmat * jointLocalCoordinatesFirstPerson(:,[1 3])')';
    
    jointLocalCoordinatesSecondPerson = jointWorldCoordinatesSecondPerson;
    jointLocalCoordinatesSecondPerson(:,[1 3]) = (rotmat * jointLocalCoordinatesSecondPerson(:,[1 3])')';
    
    %scatter3( [jointLocalCoordinatesFirstPerson(:,1); jointLocalCoordinatesSecondPerson(:,1)], [jointLocalCoordinatesFirstPerson(:,2);jointLocalCoordinatesSecondPerson(:,2)], [jointLocalCoordinatesFirstPerson(:,3);jointLocalCoordinatesSecondPerson(:,3)] );
    %axis equal
    
    
end

