# read in divorce data
setwd("~/")
library(readxl)
divorce <- read_excel("divorce.xlsx")
# set seed, find testing and training data 
set.seed(1)
testN = floor(0.7*nrow(divorce))
trainInd = sample(seq_len(nrow(divorce)),size = testN)
train = divorce[trainInd,]
test = divorce[-trainInd,]
yTrain = train$Class
train = train[,-55]
yTest = test$Class
test = test[,-55]

# Predict class using LDA modeled with all of the predictors available
library(MASS)
lda.full=lda(yTrain~.,data=train)
lda.pred=predict(lda.full,test)
lda.class=lda.pred$class
table(lda.class,yTest)

# Find the most important features by forward selection
library(leaps)
regfit.fwd = regsubsets(yTrain~.,data=train,method="forward")
fwd.sum = summary(regfit.fwd)
fwd.sum$outmat

# Compare the forward stepwise selection LDA model to the test data
lda.fwd = lda(yTrain~Atr40+Atr17+Atr6+Atr18+Atr49+Atr14+Atr24+Atr50, data=train)
lda.fwd.pred=predict(lda.fwd,test)
lda.fwd.class = lda.fwd.pred$class
table(lda.fwd.class,yTest)

# Find the most important features by backward stepwise selection
regfit.bwd = regsubsets(yTrain~.,data=train,method="backward")
bwd.sum = summary(regfit.bwd)
bwd.sum$outmat

# Compare the backward stepwise selection LDA model to the test data
lda.bwd = lda(yTrain~Atr40+Atr14+Atr6+Atr17+Atr49+Atr23+Atr26+Atr53,data=train)
lda.bwd.pred = predict(lda.bwd,test)
lda.bwd.class = lda.bwd.pred$class
table(lda.bwd.class,yTest)

# Compute the variance of each model
full.LDA = matrix(0,50,52)
fwd.LDA = matrix(0,50,52)
bwd.LDA = matrix(0,50,52)
err.full = rep(0,52)
err.fwd = rep(0,52)
err.bwd = rep(0,52)
# Loop through 50 seeds to get different test and training data
for(i in 1:50){
  set.seed(i)
  testN = floor(0.7*nrow(divorce))
  trainInd = sample(seq_len(nrow(divorce)),size = testN)
  train = divorce[trainInd,]
  test = divorce[-trainInd,]
  yTrain = train$Class
  train = train[,-55]
  yTest = test$Class
  test = test[,-55]
  # full model
  lda.full=lda(yTrain~.,data=train)
  lda.pred=predict(lda.full,test)
  lda.class=lda.pred$class
  full.LDA[i,] = lda.class
  err.full[i] = mean((lda.class - yTest)^2)
  # forward stepwise selection model
  lda.fwd = lda(yTrain~Atr40+Atr19+Atr9+Atr6+Atr18+Atr15+Atr39+Atr11+Atr13+Atr3, data=train)
  lda.fwd.pred=predict(lda.fwd,test)
  lda.fwd.class = lda.fwd.pred$class
  fwd.LDA[i,] = lda.fwd.class
  err.fwd[i] = mean((lda.fwd.class - yTest)^2)
  # backward stepwise selection model
  lda.bwd = lda(yTrain~Atr18+Atr38+Atr6+Atr29+Atr9+Atr7+Atr20+Atr15,data=train)
  lda.bwd.pred = predict(lda.bwd,test)
  lda.bwd.class = lda.bwd.pred$class
  bwd.LDA[i,] = lda.bwd.class
  err.bwd[i] = mean((lda.bwd.class - yTest)^2)
}

# get standard deviation (used to represent variance) for each attribute/feature in each model, calculated over the 50 models
library(matrixStats)
colSdFull = colSds(full.LDA)
colSdFwd = colSds(fwd.LDA)
colSdBwd = colSds(bwd.LDA)

# create a box plot of the models
sdData = c(err.full,err.fwd,err.bwd)
type = c(rep("Full Model",52), rep("Forward Selection",52), rep("Backward Selection",52))
boxplot(sdData~type,main="Test Errors of LDA Models",xlab="Parameter Selection Type", ylab="Standard Deviation")

# calculate mean and median values of the standard deviations
medFull = median(colSdFull) # 0.1414
medFwd = median(colSdFwd) # 0
medBwd = median(colSdBwd) # 0
mnFull = mean(colSdFull) # 0.1815
mnFwd = mean(colSdFwd) # 0.1189
mnBwd = mean(colSdBwd) # 0.1284





