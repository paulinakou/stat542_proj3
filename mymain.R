if (!require(dummies)) {
  install.packages("dummies")
}
if (!require(glmnet)) {
  install.packages("glmnet")
}
if (!require(e1071)) {
  install.packages("e1071")
}

library("dummies")
library("glmnet")
library("e1071")


#Load the data set
trainData<-read.csv("train.csv")
testData<-read.csv("test.csv")
train = trainData
test = testData

#Label as 1 or 0
response = ifelse(train$loan_status %in% c('Default', 'Charged Off', 'Late (31-120 days)', 'Late (16-30 days)', 
                                           'Does not meet the credit policy. Status:Charged Off'), 1, 0)

#Remove troublesome variables
train<-train[ , !(names(train) %in% c("mths_since_last_delinq", "mths_since_last_record", "mths_since_last_major_derog", 
                                      "annual_inc_joint", "dti_joint", "open_acc_6m", "open_il_6m", "open_il_12m", 
                                      "open_il_24m", "mths_since_rcnt_il", "total_bal_il", "il_util", "open_rv_12m", 
                                      "open_rv_24m", "max_bal_bc", "all_util", "inq_fi", "total_cu_tl", "inq_last_12m", 
                                      "emp_title", "issue_d", "pymnt_plan", "url", "desc", "title", "zip_code", "addr_state", 
                                      "earliest_cr_line", "last_pymnt_d", "next_pymnt_d", "last_credit_pull_d", "application_type", 
                                      "verification_status_joint", "grade", "id", "member_id", "policy_code"))]
test <- test[, names(test) %in% names(train)]


#Numerical and categorical features
feature_classes <- sapply(names(train),function(x){class(train[[x]])})
numeric_feats <-names(feature_classes[feature_classes != "factor"])
categorical_feats <-names(feature_classes[feature_classes == "factor"])

#Impute median to remaining NAs
for (i in numeric_feats) {
  na.id = is.na(train[, i])
  tmp.median = median(train[, i], na.rm=TRUE)
  train[which(na.id), i] = tmp.median
  
  na.id = is.na(test[, i])
  test[which(na.id), i] = tmp.median
}

#Transform excessively skewed features
skewed_feats <- sapply(numeric_feats,function(x){skewness(train[[x]],na.rm=TRUE)})
skewed_feats <- skewed_feats[skewed_feats > 0.7]
for(x in names(skewed_feats)) {
  train[[x]] <- log(train[[x]] + 1)
  test[[x]] <- log(test[[x]] + 1)
}

#Dummy Variables
data = rbind(train[,names(test)], test)
dummy.var = dummy.data.frame(data, categorical_feats, sep='')

#Split
train.id = 1:length(response)
train = dummy.var[train.id, ]
test = dummy.var[-train.id, ]
train$loan_status = response


#Fit logistic model
log.model = glm(loan_status ~ ., data=train, family=binomial)

#Predict
probabilities = predict(log.model, test, type="response")
Pred <- data.frame(id= testData$id, prob= probabilities)
write.table(Pred, "mysubmission1.txt",sep=",",row.names=FALSE)
