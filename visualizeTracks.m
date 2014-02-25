function visualizeTracks( sceneDataSet, sceneNum )
%VISUALIZETRACKS Summary of this function goes here
%   Detailed explanation goes here
    
    sceneData = sceneDataSet{ sceneNum };
    annotations = dlmread(['dataset/seq', num2str(sceneNum, '%02d'), '/annotations.txt']);
    
    for f=1:length(sceneData)
        
        bbgts = annotations(annotations(:,1)==f,2:5);
        actiongts = annotations(annotations(:,1)==f,6);
            
        if ~isempty( sceneData{f} ) & ~isempty(bbgts)
           locs = [sceneData{f}.loc]';
           bbs = [sceneData{f}.bb]';   
           dirs = [sceneData{f}.direction]';
           actions = zeros( size( locs,1), 1 );
           
           for j=1:size(bbs,1)
                bb = bbs(j,:);
                ovmax = 0;
                for k=1:size(bbgts,1)
                    bbgt = bbgts(k,:);
                    bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(1)+bb(3),bbgt(1)+bbgt(3)) ; min(bb(2)+bb(4),bbgt(2)+bbgt(4))];
                    iw=bi(3)-bi(1)+1;
                    ih=bi(4)-bi(2)+1;
                    if iw>0 & ih>0                
                        ua=(bb(3))*(bb(4))+bbgt(3)*bbgt(4)-iw*ih;
                        ov=iw*ih/ua;
                        if ov>ovmax
                            ovmax=ov;
                            kmax=k;
                        end
                    end
                end
                if ovmax == 0 % no match
                    actions(j) = -1;
                else
                    actions(j) = actiongts(kmax);
                end
           end
           
           locs = locs( actions ~= -1,: );
           dirs = dirs( actions ~= -1 );
           actions = actions( actions ~= -1);
           
           if ~isempty(actions)
               dummyloc = -ones( 8, 2 );
               dummyact = zeros( 8, 1 );
               dummyact(:,1) = [1:8];
                              
               tempactions = actions(dirs==0);
               templocs = locs(dirs==0,:);
               tempactions = [tempactions ; dummyact];
               templocs = [templocs ; dummyloc];
               gscatter( templocs(:,1), templocs(:,2), tempactions, 'bgrcmyk', '>' );
               hold on;
               
               tempactions = actions(dirs==pi/2);
               templocs = locs(dirs==pi/2,:);
               tempactions = [tempactions ; dummyact];
               templocs = [templocs ; dummyloc];
               gscatter( templocs(:,1), templocs(:,2), tempactions, 'bgrcmyk', 'v' );
               hold on;
               
               tempactions = actions(dirs==pi);
               templocs = locs(dirs==pi,:);
               tempactions = [tempactions ; dummyact];
               templocs = [templocs ; dummyloc];
               gscatter( templocs(:,1), templocs(:,2), tempactions, 'bgrcmyk', '<' );
               hold on;
               
               tempactions = actions(dirs==3*pi/2);
               templocs = locs(dirs==3*pi/2,:);
               tempactions = [tempactions ; dummyact];
               templocs = [templocs ; dummyloc];
               gscatter( templocs(:,1), templocs(:,2), tempactions, 'bgrcmyk', '^' );
               
               MyBox = uicontrol('style','text');
               set(MyBox,'String',num2str(f));
               set(MyBox,'Position',[100,100,30,30]);
               xlim( [-6 6] );
               ylim( [0 10] );
               legend('NA','Crossing','Waiting','Queuing','Walking','Talking','Dancing','Jogging');

               %imshow( ['dataset/seq', num2str(sceneNum, '%02d') '/frame' num2str(f, '%04d') '.jpg'] );

               pause(0.05);
               
               hold off
           end
        end        
    end
end

