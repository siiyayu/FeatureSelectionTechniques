data <- read.csv("ifood_df.csv")


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

source("naref.R")
newdesign <- as.data.frame(lapply(newdesign, function(col) {
  if (length(unique(col)) <= 3) naref(col) else col
}))

#dense matrix
design_lasso <- model.matrix(~. - campaign_total, data = newdesign)[,-1]

sparse_matrix <- as(design_lasso, "dgCMatrix")

y <- as.matrix(newdesign$campaign_total)

library(gamlr)
library(Matrix)

#use cv lasso
lasso <- cv.gamlr(sparse_matrix, y, verb=TRUE, lambda.min.ratio=1e-4,family = "poisson")
plot(lasso)

beta <- coef(lasso, select = "min")
o <- order(abs(beta),decreasing = TRUE)
beta <- drop(beta)
beta
beta[o][-1][1:10]


predictions_lasso <- predict(lasso, design_lasso, select = "min")


#trying new matrix (remove some colnums)

#correlation matrix
newdesign_forcor <-  newdesign[, !colnames(newdesign) %in% c( "Income"
)]
cor_matrix <- cor(newdesign_forcor[, apply(newdesign_forcor, 2, function(x) !all(x %in% c(0, 1)))])
which(abs(cor_matrix) > 0.7 & abs(cor_matrix)<1, arr.ind = TRUE)

##only remove income
newdesign <- newdesign[, !colnames(newdesign) %in% c( "Income"
)]


#dense matrix
design_lasso <- model.matrix(~. - campaign_total, data = newdesign)[,-1]

sparse_matrix <- as(design_lasso, "dgCMatrix")

y <- as.matrix(newdesign$campaign_total)

#use cv lasso
lasso <- cv.gamlr(sparse_matrix, y, verb=TRUE, lambda.min.ratio=1e-4,family = "poisson")
plot(lasso)

beta <- coef(lasso, select = "min")
beta

predictions_lasso <- predict(lasso, design_lasso, select = "min")

