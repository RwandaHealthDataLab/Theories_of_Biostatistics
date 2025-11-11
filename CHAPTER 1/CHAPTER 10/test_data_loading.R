# Test script to debug data loading issues
# Chapter 10 - HORMONE.DAT
# ========================================

cat("=================================================\n")
cat("Testing Data Loading for HORMONE.DAT\n")
cat("=================================================\n\n")

# Set working directory
setwd("C:/Users/ValensRwema/Desktop/Theories of Biostatistics/Theories of Biostatistics/CHAPTER 10")

# Define data path
data_path <- "Rosner_FundamentalsBiostatistics_8e_Data_Sets/ASCII-comma/HORMONE.DAT.txt"

cat("Step 1: Checking if file exists...\n")
if(file.exists(data_path)) {
  cat("  SUCCESS: File found at:", data_path, "\n\n")
} else {
  cat("  ERROR: File not found!\n")
  cat("  Looking for:", data_path, "\n")
  stop("Please check the file path.")
}

cat("Step 2: Reading first few lines to inspect format...\n")
first_lines <- readLines(data_path, n = 5)
cat("  First 5 lines of file:\n")
for(i in 1:length(first_lines)) {
  cat("  Line", i, ":", first_lines[i], "\n")
}
cat("\n")

cat("Step 3: Attempting to load data (Method 1 - basic read.csv)...\n")
tryCatch({
  hormone_data_v1 <- read.csv(data_path, header = TRUE)
  cat("  SUCCESS: Data loaded with basic read.csv\n")
  cat("  Dimensions:", nrow(hormone_data_v1), "rows x", ncol(hormone_data_v1), "columns\n")
  cat("  Column names:", paste(colnames(hormone_data_v1), collapse = ", "), "\n\n")

  # Check for the Hormone column
  if("Hormone" %in% colnames(hormone_data_v1)) {
    cat("  Hormone column found!\n")
    cat("  Unique values:", paste(unique(hormone_data_v1$Hormone), collapse = ", "), "\n\n")
  } else {
    cat("  WARNING: 'Hormone' column not found\n")
    cat("  Available columns:", paste(colnames(hormone_data_v1), collapse = ", "), "\n\n")
  }
}, error = function(e) {
  cat("  ERROR:", conditionMessage(e), "\n\n")
})

cat("Step 4: Attempting to load data (Method 2 - with quote handling)...\n")
tryCatch({
  hormone_data_v2 <- read.csv(data_path, header = TRUE, strip.white = TRUE, quote = "'\"")

  # Clean column names
  colnames(hormone_data_v2) <- gsub("'", "", colnames(hormone_data_v2))
  colnames(hormone_data_v2) <- gsub("\"", "", colnames(hormone_data_v2))

  cat("  SUCCESS: Data loaded with quote handling\n")
  cat("  Dimensions:", nrow(hormone_data_v2), "rows x", ncol(hormone_data_v2), "columns\n")
  cat("  Column names:", paste(colnames(hormone_data_v2), collapse = ", "), "\n\n")

  # Check for the Hormone column
  if("Hormone" %in% colnames(hormone_data_v2)) {
    cat("  Hormone column found!\n")
    cat("  Unique values:", paste(unique(hormone_data_v2$Hormone), collapse = ", "), "\n\n")
  } else {
    cat("  WARNING: 'Hormone' column not found\n")
    cat("  Available columns:", paste(colnames(hormone_data_v2), collapse = ", "), "\n\n")
  }
}, error = function(e) {
  cat("  ERROR:", conditionMessage(e), "\n\n")
})

cat("Step 5: Attempting to load data (Method 3 - read.table)...\n")
tryCatch({
  hormone_data_v3 <- read.table(data_path, header = TRUE, sep = ",", quote = "'\"")

  # Clean column names
  colnames(hormone_data_v3) <- gsub("'", "", colnames(hormone_data_v3))
  colnames(hormone_data_v3) <- gsub("\"", "", colnames(hormone_data_v3))

  cat("  SUCCESS: Data loaded with read.table\n")
  cat("  Dimensions:", nrow(hormone_data_v3), "rows x", ncol(hormone_data_v3), "columns\n")
  cat("  Column names:", paste(colnames(hormone_data_v3), collapse = ", "), "\n\n")

  # Check for the Hormone column
  if("Hormone" %in% colnames(hormone_data_v3)) {
    cat("  Hormone column found!\n")
    cat("  Unique values:", paste(unique(hormone_data_v3$Hormone), collapse = ", "), "\n\n")
  } else {
    cat("  WARNING: 'Hormone' column not found\n")
    cat("  Available columns:", paste(colnames(hormone_data_v3), collapse = ", "), "\n\n")
  }
}, error = function(e) {
  cat("  ERROR:", conditionMessage(e), "\n\n")
})

cat("Step 6: Testing data manipulation with tidyverse...\n")
tryCatch({
  library(tidyverse)

  # Use the most successful method from above
  hormone_data <- read.csv(data_path, header = TRUE, strip.white = TRUE, quote = "'\"")
  colnames(hormone_data) <- gsub("'|\"", "", colnames(hormone_data))

  # Test the mutation that was failing
  hormone_data_test <- hormone_data %>%
    mutate(
      Hormone_Group = factor(Hormone,
                            levels = 1:5,
                            labels = c("Saline (Control)",
                                     "Secretin",
                                     "Cholecystokinin",
                                     "Gastrin",
                                     "CCK+Secretin"))
    )

  cat("  SUCCESS: Data manipulation with tidyverse works!\n")
  cat("  Hormone_Group created successfully\n")
  cat("  Hormone group counts:\n")
  print(table(hormone_data_test$Hormone_Group))
  cat("\n")

}, error = function(e) {
  cat("  ERROR:", conditionMessage(e), "\n")
  cat("  This is the error you're experiencing in the R Markdown document.\n\n")
})

cat("=================================================\n")
cat("Step 7: Displaying sample of loaded data...\n")
cat("=================================================\n\n")
if(exists("hormone_data")) {
  cat("First 10 rows of data:\n")
  print(head(hormone_data, 10))
  cat("\n\nSummary statistics:\n")
  print(summary(hormone_data))
}

cat("\n=================================================\n")
cat("Testing completed!\n")
cat("=================================================\n\n")

cat("RECOMMENDATION:\n")
cat("If all steps succeeded, your R Markdown document should work.\n")
cat("If Step 6 failed, check:\n")
cat("  1. tidyverse is properly installed\n")
cat("  2. The 'Hormone' column name is correct\n")
cat("  3. No special characters in column names\n\n")

cat("Run this script to identify the issue:\n")
cat("  source('test_data_loading.R')\n\n")
