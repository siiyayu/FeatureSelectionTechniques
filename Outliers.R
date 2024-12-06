# Load necessary libraries
library(ggplot2)
library(gridExtra)
library(readr)

setwd("/Users/andrewbelyaev/UIUC/STAT 527/STAT527 Final Project")

# Load the dataset
ifood_df <- read_csv("ifood_df.csv")

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
newdesign_1 <- as.data.frame(lapply(newdesign, function(col) {
  if (length(unique(col)) <= 3) factor(col) else col
}))

source("naref.R")
newdesign <- as.data.frame(lapply(newdesign, function(col) {
  if (length(unique(col)) <= 3) naref(col) else col
}))




# Select only numerical columns for boxplot analysis
numerical_cols <- sapply(ifood_df, is.numeric)
numerical_data <- ifood_df[, numerical_cols]

# Create boxplots
plot_list <- lapply(names(numerical_data), function(col_name) {
  ggplot(numerical_data, aes_string(y = col_name)) +
    geom_boxplot() +
    ggtitle(paste("Boxplot of", col_name)) +
    theme_minimal()
})

# Arrange plots in groups of 10 and display them in RStudio
plots_per_page <- 10
num_pages <- ceiling(length(plot_list) / plots_per_page)

for (i in seq_len(num_pages)) {
  start_index <- (i - 1) * plots_per_page + 1
  end_index <- min(i * plots_per_page, length(plot_list))
  
  grid.arrange(
    grobs = plot_list[start_index:end_index],
    ncol = 2,  # Arrange 2 plots per row
    top = paste("Boxplots: Page", i)
  )
}
