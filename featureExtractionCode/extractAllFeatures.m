function extractAllFeatures( numTemporalSamples, numPcaBasis, trainSequenceNum )

    nameActions = {'001_sh1', '002_sh2', '003_card', '004_ball', '005_box', '006_cup', '007_chair', '008_bow', '009_fistbump', '010_h10'};

    for act = 1:length(nameActions)

        nameFolds = dir(nameActions{act});
        for i=1:length(nameFolds)
            if strcmp(nameFolds(i).name,'.') || strcmp(nameFolds(i).name,'..')
                continue;
            end

            [nameActions{act} '/' nameFolds(i).name]
            
            feature = extractFeatures( [nameActions{act} '/' nameFolds(i).name] );
            feature = interpft(feature, numTemporalSamples);            

            allFeatures(act,i-2).action = act;
            allFeatures(act,i-2).seq = nameFolds(i).name;
            allFeatures(act,i-2).feature = feature;            
                        
        end
    end
    
    save('allFeatures', 'allFeatures');
    
    % compute PCA
    trainFeature = [];
    
    for i=1:size(allFeatures,1)
        for j=1:trainSequenceNum
            for k=1:size(allFeatures(i,j).feature,1)
                trainFeature = [trainFeature ; allFeatures(i,j).feature(k,:)];
            end
        end
    end
    
    meanTrainFeature = mean( trainFeature );
    trainFeature = trainFeature - repmat( meanTrainFeature, size(trainFeature,1), 1 );    
    
    [pcaBasis,score,latent] = pca(trainFeature, 'NumComponents', numPcaBasis );  
    
    % dim reduction
    for i=1:size(allFeatures,1)
        for j=1:size(allFeatures,2)
            for k=1:size(allFeatures(i,j).feature,1)
                pcaFeatures(i,j).feature(k,:) = ( allFeatures(i,j).feature(k,:) - meanTrainFeature ) * pcaBasis;
            end
        end
    end
    
    save('pcaFeatures', 'pcaFeatures');
        
    % save final train and test data
    countTrain = 1;
    countTest = 1;
    for i=1:size(pcaFeatures,1)
        for j=1:size(pcaFeatures,2)
            if ~isempty(pcaFeatures(i,j).feature)
                if j<=trainSequenceNum
                    trainX(countTrain,:) = pcaFeatures(i,j).feature(:)';
                    trainT(countTrain) = i;
                    countTrain = countTrain + 1;
                else
                    testX(countTest,:) = pcaFeatures(i,j).feature(:)';
                    testT(countTest) = i;
                    countTest = countTest + 1;
                end
            end
        end
    end
    
    trainT = trainT';
    testT = testT';
   
    save('trainX', 'trainX');
    save('trainT', 'trainT');
    save('testX', 'testX');
    save('testT', 'testT');
end
