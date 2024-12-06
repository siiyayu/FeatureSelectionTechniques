View(design)
newdesign <- data[, !colnames(data) %in% c( "Z_CostContact", 
                                        "Z_Revenue","MntTotal","MntRegularProds",
                                        "AcceptedCmpOverall"
)]

newdesign$campaign_total <- rowSums(newdesign[, c("AcceptedCmp1", "AcceptedCmp2", "AcceptedCmp3",
                                           "AcceptedCmp4","AcceptedCmp5","Response")])


newdesign <- newdesign[, !colnames(newdesign) %in% c( "AcceptedCmp1", "AcceptedCmp2", "AcceptedCmp3",
                                                      "AcceptedCmp4","AcceptedCmp5","Response"
)]

#factor
newdesign <- as.data.frame(lapply(newdesign, function(col) {
  if (length(unique(col)) <= 3) factor(col) else col
}))


poissonml <- glm(campaign_total ~ ., data = newdesign, family = poisson)
summary(poissonml)

newdesign1 <- newdesign[, !colnames(newdesign) %in% c( "AcceptedCmp1", "AcceptedCmp2", "AcceptedCmp3",
                                                      "AcceptedCmp4","AcceptedCmp5","Response","education_PhD"
                                                      ,"marital_Widow"
)]
newdesign1 <- as.data.frame(lapply(newdesign1, function(col) {
  if (length(unique(col)) <= 3) factor(col) else col
}))


poissonml_new1 <- glm(campaign_total ~ ., data = newdesign1, family = poisson)
summary(poissonml_new1)

library(faraway)
vif(poissonml_new1)


newdesign2 <- newdesign[, !colnames(newdesign) %in% c( "AcceptedCmp1", "AcceptedCmp2", "AcceptedCmp3",
                                                       "AcceptedCmp4","AcceptedCmp5","Response","education_PhD"
                                                       ,"marital_Widow","marital_Married" #,"Income"
)]
newdesign2 <- as.data.frame(lapply(newdesign2, function(col) {
  if (length(unique(col)) <= 3) factor(col) else col
}))


poissonml_new2 <- glm(campaign_total ~ ., data = newdesign2, family = poisson)
summary(poissonml_new2)

vif(poissonml_new2)


#correlation matrix
#newdesign2_forcor <-  newdesign[, !colnames(newdesign) %in% c( "AcceptedCmp1", "AcceptedCmp2", "AcceptedCmp3",
 #                                                              "AcceptedCmp4","AcceptedCmp5","Response","education_PhD"
 #                                                              ,"marital_Widow","marital_Married"
#)]
#cor_matrix <- cor(newdesign2_forcor[, apply(newdesign2_forcor, 2, function(x) !all(x %in% c(0, 1)))])
#which(abs(cor_matrix) > 0.7 & abs(cor_matrix)<1, arr.ind = TRUE)





######    using cross validation   ########
nfold <- 10 # the number of OOS validation `folds'
n<- nrow(newdesign2)
foldid <- rep(1:nfold,each=ceiling(n/nfold))[sample(1:n)]


#mse
MSE <- NULL
for(k in 1:nfold){ 
  
  train <- which(foldid!=k) # train on all but fold `k'
  
  poisson_train <- glm(campaign_total ~ ., data = newdesign2, subset = train, family = poisson)
  
  poisson_test <- predict(poisson_train, newdata=newdesign2[-train,], type="response")
  
  y_true <- newdesign2[-train,]$campaign_total
  MSE <- c(MSE, mean((as.vector(poisson_test) - as.vector(y_true))^2))
}

MSE <- mean(MSE)
MSE   #0.5458878 with income    #0.5985679 without income
 

#AIC
AIC <- NULL
for(k in 1:nfold){ 
  
  train <- which(foldid!=k) # train on all but fold `k'
  
  poisson_train <- glm(campaign_total ~ ., data = newdesign2, subset = train, family = poisson)


  AIC <- c(AIC, AIC(poisson_train))
  
}

AIC <- mean(AIC)
AIC   #2948.662

#trying categorize count values 0 and >0
accuracy <- NULL
for(k in 1:nfold){ 
  
  train <- which(foldid!=k) # train on all but fold `k'
  
  poisson_train <- glm(campaign_total ~ ., data = newdesign2, subset = train, family = poisson)
  
  poisson_test <- predict(poisson_train, newdata=newdesign2[-train,], type="response")
  
  poisson_test <- sapply(poisson_test, function(x) x > 0.5)

  
  y_true <- newdesign2[-train,]$campaign_total
  y_true <- sapply(y_true, function(x) x > 0)

  
  accuracy <- c(accuracy, sum(y_true == poisson_test)/length(y_true))
}

accuracy <- mean(accuracy)
accuracy   #0.7826923

#plot ROC
roc_prediction <- NULL
roc_true <- NULL
for(k in 1:nfold){ 
  
  train <- which(foldid!=k) # train on all but fold `k'
  
  poisson_train <- glm(campaign_total ~ ., data = newdesign2, subset = train, family = poisson)
  
  poisson_test <- predict(poisson_train, newdata=newdesign2[-train,], type="response")
  
  poisson_test <- sapply(poisson_test, function(x) x > 0.5)
  poisson_test <- as.numeric(poisson_test)
  roc_prediction <- c(roc_prediction, poisson_test)
  
  y_true <- newdesign2[-train,]$campaign_total
  y_true <- sapply(y_true, function(x) x > 0)
  y_true <- as.numeric(y_true)
  roc_true <- c(roc_true, y_true)
  
}

library(pROC)
roc_curve <- roc(roc_true, roc_prediction)
plot(roc_curve)
auc(roc_curve) 



cooks.distance(poissonml_new2)
plot(cooks.distance(poissonml_new2))
