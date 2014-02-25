function sceneDataSet = convertData
%CONVERTDATA Summary of this function goes here
%   Detailed explanation goes here
    
    addpath( 'dataset/tracks');
    sceneDataSet = cell(72,1);
    
    for i=1:72
        tracks = readTracks(['dataset/tracks/track' num2str(i) '.dat']);
        
        maxFrameNum=0;
        for t=1:length(tracks)
            if maxFrameNum < tracks(t).te
                maxFrameNum = tracks(t).te;
            end
        end
               
        sceneData = cell(maxFrameNum,1);
        
        for t=1:length(tracks)
            for f=[tracks(t).ti : tracks(t).te]
                switch tracks(t).locs(4,f-tracks(t).ti+1)
                   case 1
                      dir = 0;
                   case 2
                      dir = pi/2;
                   case 3
                      dir = pi;
                   case 4
                      dir = 3*pi/2;                    
                end
                st = struct( 'id', tracks(t).id, 'bb', tracks(t).bbs(:,f-tracks(t).ti+1), 'loc', tracks(t).locs(1:2,f-tracks(t).ti+1), 'direction', dir );
                                
                if isempty( sceneData{f} )
                    sceneData{f} = st;
                else
                    sceneData{f}(end+1) = st;
                end               
            end
        end
        
        sceneDataSet{i} = sceneData;       
        
    end
    
    save('sceneDataSet', 'sceneDataSet' );

end

