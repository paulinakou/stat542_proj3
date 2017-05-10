library("randomForest")
#Merge
trainData<-read.csv("train.csv")
testData<-read.csv("test.csv")

train<-rbind(trainData[,-which(names(trainData) %in% c("loan_status"))],testData)
#remove some factors
train=train[,colSums(is.na(train)) == 0]
temp<-train[ , -which(names(train) %in% c("pymnt_plan","out_prncp_inv","policy_code","application_type","verification_status_joint","dti","member_id","emp_title","issue_d","url","desc","title","zip_code","earliest_cr_line","last_pymnt_d","next_pymnt_d","last_credit_pull_d"))]


#Split
tempid=1:nrow(trainData)
temptest=temp[-tempid,]
temp=temp[tempid,]

#add back response
temp$loan_status <- trainData$loan_status
#temp<-temp[,-which(names(trainData) %in% c("loan_status"))]

#remove current loans
current_id <- which(temp$loan_status %in% c("Current"))
temp <- temp[-current_id,]
temp$loan_status <- factor(temp$loan_status)


#label as 1 or 0
y <- factor(temp$loan_status)
levels(y)[levels(y)=="Default"] <- "1"
levels(y)[levels(y)=="Charged Off"] <- "1"
levels(y)[levels(y)=="Late (16-30 days)"] <- "1"
levels(y)[levels(y)=="Late (31-120 days)"] <- "1"
levels(y)[levels(y)=="Fully Paid"] <- "0"
levels(y)[levels(y)=="In Grace Period"] <- "0"
levels(y)[levels(y)=="Issued"] <- "0"
levels(y)[levels(y)=="Does not meet the credit policy. Status:Charged Off"] <- "1"
levels(y)[levels(y)=="Does not meet the credit policy. Status:Fully Paid"] <- "0"
temp$loan_status <- y

#Train Random Forest
fit <- randomForest(loan_status ~., data=temp, ntree=700)

#Predict
prediction <- predict(fit, newdata = temptest, type="prob")

probabilities <- prediction[,1]
Pred <- data.frame(id= testData$id, prob= probabilities)

#write.csv(probabilities,"myprediction1.csv")
write.table(Pred, "mysubmission.txt",sep=",",row.names=FALSE)
