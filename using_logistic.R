data <- read.csv("ifood_df.csv")


design <- data[, !colnames(data) %in% c("AcceptedCmp1", "AcceptedCmp2", "AcceptedCmp3",
                                        "AcceptedCmp4","AcceptedCmp5", "Z_CostContact", 
                                        "Z_Revenue","MntTotal","MntRegularProds",
                                        "AcceptedCmpOverall"
                                        )]



dim(design)


design <- data[, !colnames(data) %in% c( "Z_CostContact", 
                                        "Z_Revenue","MntTotal","MntRegularProds",
                                        "AcceptedCmpOverall"
)]

#factor
design <- as.data.frame(lapply(design, function(col) {
  if (length(unique(col)) <= 3) factor(col) else col
}))


#correlation matrix
cor_matrix <- cor(design[, apply(design, 2, function(x) !all(x %in% c(0, 1)))])
which(abs(cor_matrix) > 0.7 & abs(cor_matrix)<1, arr.ind = TRUE)


library(faraway)
logistic <- glm(Response ~ ., data = design, family = binomial)
summary(logistic2)    #detect severe collinearity


vif <- vif(logistic)


design2 <- data[, !colnames(data) %in% c( "Z_CostContact", 
                                         "Z_Revenue","MntTotal","MntRegularProds",
                                         "AcceptedCmpOverall","education_Basic","marital_Widow"
)]
design2 <- as.data.frame(lapply(design2, function(col) {
  if (length(unique(col)) <= 3) factor(col) else col
}))
logistic2 <- glm(Response ~ ., data = design2, family = binomial)
summary(logistic2)

vif(logistic2)

design3 <- data[, !colnames(data) %in% c( "Z_CostContact", 
                                          "Z_Revenue","MntTotal","MntRegularProds",
                                          "AcceptedCmpOverall","marital_Widow"
                                          ,"education_Graduation", "Income"
)]
design3 <- as.data.frame(lapply(design3, function(col) {
  if (length(unique(col)) <= 3) factor(col) else col
}))
logistic3 <- glm(Response ~ ., data = design3, family = binomial)
summary(logistic3)

vif(logistic3)
