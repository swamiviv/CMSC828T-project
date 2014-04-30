function sticks = calcSticks( jointLocalCoordinatesOnePerson )
%CALCSTICKS Summary of this function goes here
%   Detailed explanation goes here

    % stick is represented as 3d positions of starting and ending points
    
    sticks{1}(1,:) = jointLocalCoordinatesOnePerson(1,:);
    sticks{1}(2,:) = jointLocalCoordinatesOnePerson(2,:);
    
    sticks{2}(1,:) = jointLocalCoordinatesOnePerson(2,:);
    sticks{2}(2,:) = jointLocalCoordinatesOnePerson(3,:);
    
    sticks{3}(1,:) = jointLocalCoordinatesOnePerson(3,:);
    sticks{3}(2,:) = jointLocalCoordinatesOnePerson(4,:);
    
    sticks{4}(1,:) = jointLocalCoordinatesOnePerson(3,:);
    sticks{4}(2,:) = jointLocalCoordinatesOnePerson(5,:);
    
    sticks{5}(1,:) = jointLocalCoordinatesOnePerson(3,:);
    sticks{5}(2,:) = jointLocalCoordinatesOnePerson(9,:);
    
    sticks{6}(1,:) = jointLocalCoordinatesOnePerson(5,:);
    sticks{6}(2,:) = jointLocalCoordinatesOnePerson(6,:);
    
    sticks{7}(1,:) = jointLocalCoordinatesOnePerson(9,:);
    sticks{7}(2,:) = jointLocalCoordinatesOnePerson(10,:);

    sticks{8}(1,:) = jointLocalCoordinatesOnePerson(6,:);
    sticks{8}(2,:) = jointLocalCoordinatesOnePerson(7,:);
    
    sticks{9}(1,:) = jointLocalCoordinatesOnePerson(10,:);
    sticks{9}(2,:) = jointLocalCoordinatesOnePerson(11,:);
    
    sticks{10}(1,:) = jointLocalCoordinatesOnePerson(7,:);
    sticks{10}(2,:) = jointLocalCoordinatesOnePerson(8,:);
    
    sticks{11}(1,:) = jointLocalCoordinatesOnePerson(11,:);
    sticks{11}(2,:) = jointLocalCoordinatesOnePerson(12,:);
    
    sticks{12}(1,:) = jointLocalCoordinatesOnePerson(1,:);
    sticks{12}(2,:) = jointLocalCoordinatesOnePerson(13,:);
    
    sticks{13}(1,:) = jointLocalCoordinatesOnePerson(1,:);
    sticks{13}(2,:) = jointLocalCoordinatesOnePerson(17,:);
    
    sticks{14}(1,:) = jointLocalCoordinatesOnePerson(13,:);
    sticks{14}(2,:) = jointLocalCoordinatesOnePerson(14,:);
    
    sticks{15}(1,:) = jointLocalCoordinatesOnePerson(17,:);
    sticks{15}(2,:) = jointLocalCoordinatesOnePerson(18,:);
    
    sticks{16}(1,:) = jointLocalCoordinatesOnePerson(14,:);
    sticks{16}(2,:) = jointLocalCoordinatesOnePerson(15,:);
    
    sticks{17}(1,:) = jointLocalCoordinatesOnePerson(18,:);
    sticks{17}(2,:) = jointLocalCoordinatesOnePerson(19,:);
    
    sticks{18}(1,:) = jointLocalCoordinatesOnePerson(15,:);
    sticks{18}(2,:) = jointLocalCoordinatesOnePerson(16,:);
    
    sticks{19}(1,:) = jointLocalCoordinatesOnePerson(19,:);
    sticks{19}(2,:) = jointLocalCoordinatesOnePerson(20,:);
end

