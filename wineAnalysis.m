% Read in white wine dataset, split into test and training data
wdata = readtable('winequality-white.xlsx');
cvW = cvpartition(size(wdata,1),'HoldOut',0.3);
idxW = cvW.test;
wTrain = wdata(~idxW,:);
wTest  = wdata(idxW,:);
wTestY = wTest(:,12);
wTest(:,12) = [];
trueW = table2array(wTestY);
% Read in red wine dataset, split into test and trainng data
rdata = readtable('winequality-red.xlsx');
cvR = cvpartition(size(rdata,1),'HoldOut',0.3);
idxR = cvR.test;
rTrain = rdata(~idxR,:);
rTest  = rdata(idxR,:);
rTestY = rTest(:,12);
rTest(:,12) = [];
trueR = table2array(rTestY);
% Find linear regression models for red and white wines
mdlW = fitlm(wTrain,'linear');
mdlR = fitlm(rTrain,'linear');
% Predict values for test red and white wine, find test MSEs (round the
% values because the quality is an integer 0-10
labelW = round(predict(mdlW,wTest));
labelR = round(predict(mdlR,rTest));
errW = mean((labelW-trueW).^2);
errR = mean((labelR-trueR).^2);
% Predict values for red and white, using the opposite model
labWmdlR = round(predict(mdlR,wTest));
labRmdlW = round(predict(mdlW,rTest));
errWmdlR = mean((labWmdlR-trueW).^2);
errRmdlW = mean((labRmdlW-trueR).^2);
% Plot the data for each wine type with the regression model
figure
hold on
boxplot([trueW, labelW],{'True Level','Predicted Level'})
hold off
figure
hold on
boxplot([trueR, labelR],{'True Level of Red Wine','Predicted Level of Red Wine'})
hold off
% Graph comparing the red and white wines
figure
hold on
boxplot([trueR, labRmdlW],{'True Level of Red Wine','Predicted Red Wine Level (White Wine Model)'})
hold off
figure
hold on
boxplot([trueW, labWmdlR],{'True Level of White Wine','Predicted White Wine Level (Red Wine Model)'})
hold off

% Run through the linear model 1000 times to find mean test MSE value
errW1000 = zeros(1000,1);
errR1000 = zeros(1000,1);
for i=1:1000
    cvW = cvpartition(size(wdata,1),'HoldOut',0.3);
    idxW = cvW.test;
    wTrain = wdata(~idxW,:);
    wTest  = wdata(idxW,:);
    wTestY = wTest(:,12);
    wTest(:,12) = [];
    trueW = table2array(wTestY);
    cvR = cvpartition(size(rdata,1),'HoldOut',0.3);
    idxR = cvR.test;
    rTrain = rdata(~idxR,:);
    rTest  = rdata(idxR,:);
    rTestY = rTest(:,12);
    rTest(:,12) = [];
    trueR = table2array(rTestY);
    mdlW = fitlm(wTrain,'linear');
    mdlR = fitlm(rTrain,'linear');
    labelW = round(predict(mdlW,wTest));
    labelR = round(predict(mdlR,rTest));
    errW1000(i) = mean((labelW-trueW).^2);
    errR1000(i) = mean((labelR-trueR).^2);
end
errTrueW = mean(errW1000);
errTrueR = mean(errR1000);

% Look at data as classification instead of regression
% Classification consideration with Naive Bayes
bayMdlW = fitcnb(wTrain,'quality');
bayMdlR = fitcnb(rTrain,'quality');
bayLabelW = predict(bayMdlW,wTest);
bayLabelR = predict(bayMdlR,rTest);
errBayW = mean((bayLabelW-trueW).^2);
errBayR = mean((bayLabelR-trueR).^2);
% Graphs of Naive Bayes and True Values
figure
hold on
boxplot([trueR, bayLabelR],{'True Level of Red Wine','Bayes Predicted Level of Red Wine'})
hold off
figure
hold on
boxplot([trueW, bayLabelW],{'True Level of White Wine','Bayes Predicted Level of White Wine'})
hold off






