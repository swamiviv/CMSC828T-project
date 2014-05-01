function feature = calcRelativeGeometry( sticks )
%CALCRELATIVEGEOMETRY Summary of this function goes here
%   Detailed explanation goes here

    % input
    % sticks: 1* (numStciks) cell array of 2*3 matrix where the first row is the 3d
    % location of the starting point and the second row is for the ending
    % point
    
    numStciks = length(sticks);
    feature = [];
    
    for i=1:numStciks-1
        for j=i+1:numStciks
        
            % calc translation
            translation = sticks{j}(1,:) - sticks{i}(1,:);
            
            % take offset
            stick1end = sticks{i}(2,:) - sticks{i}(1,:);
            stick2end = sticks{j}(2,:) - sticks{j}(1,:);
          
            rotvec = vrrotvec( stick1end, stick2end );
            auaternions = qGetRotQuaternion( rotvec(4), rotvec(1:3) )';
            
            feature = [feature translation auaternions];
                        
        end
    end
    
end

