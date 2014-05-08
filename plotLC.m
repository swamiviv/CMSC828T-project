%function plotLC(trainX,trainT,testX,testT)
%Description
%This function plots learning curves for different classifiers
%

data = [trainX;testX];
labels = [trainT;testT];

splits = [0.2 0.4 0.6 0.8];
labelSet = unique(labels);


labidx = {};
for i = 1:length(splits)
    traindata = [];testdata = [];
    trainlab = []; testlab = [];
    for j = 1:length(labelSet)
        labidx = find(labels == labelSet(j));
        trainlabidx = labidx(1:round(splits(i)*length(labidx)));
        testlabidx = setdiff(labidx,trainlabidx);
        
        traindata = [traindata ;data(trainlabidx,:)];
        trainlab = [trainlab; labels(trainlabidx)];
        
        testdata = [testdata ;data(testlabidx,:)];
        testlab = [testlab; labels(testlabidx)];
               
    end
     
         % Use svm
        model = ovrtrain(trainlab,traindata,' ');
        [lab_svm_train, ~,decv_train_svm] = ovrpredict(trainlab,traindata, model);
        [lab_svm_test, ~,decv_test_svm] = ovrpredict(testlab,testdata, model);
%         
%         train_err(i) = (100-ac_train(1))/100;
%         test_err(i) = (100-ac_test(1))/100;
% %         train_err(i) = 1 - ac_train;
% %         test_err(i) = 1 - ac_test;

        %Use knn classification
        mdl = ClassificationKNN.fit(traindata,trainlab,'NumNeighbors',1);
        [train_pred_knn,train_score_knn] = predict(mdl,traindata);
        [test_pred_knn,test_score_knn] = predict(mdl,testdata);

        %Use Class. tree
        ctree = ClassificationTree.fit(traindata,trainlab);
        [train_pred_CT,train_score_CT] = predict(ctree,traindata);
        [test_pred_CT,test_score_CT] = predict(ctree,testdata);
        
        %Choose the most frequent label 
        [~,train_lab_final] = max([decv_train_svm train_score_knn train_score_CT]');
        [~,test_lab_final] = max([decv_test_svm test_score_knn test_score_CT]');
        
        train_lab_final = mod(train_lab_final',length(labelSet));
        test_lab_final = mod(test_lab_final',length(labelSet));
        
        train_lab_final(find(train_lab_final == 0)) = max(labelSet);
        test_lab_final(find(test_lab_final == 0)) = max(labelSet);
        
        train_err(i) = sum(train_lab_final ~= trainlab)/length(trainlab);
        test_err(i) = sum(test_lab_final ~= testlab)/length(testlab);
        i
end
figure; plot(train_err,'bs-','LineWidth',2);hold on; plot(test_err,'rs-','LineWidth',2);
ylabel('Classification error');xlabel('Training Set Size');ylim([0 1]);
%end
