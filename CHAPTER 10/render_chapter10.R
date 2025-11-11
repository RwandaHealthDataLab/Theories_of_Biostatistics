# Script to render Chapter 10 R Markdown document
# Hepatic Disease Analysis
# ========================================

# Set working directory to the location of this script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Alternative if not using RStudio:
# setwd("C:/Users/ValensRwema/Desktop/Theories of Biostatistics/Theories of Biostatistics/CHAPTER 10")

cat("=================================================\n")
cat("Chapter 10: Hepatic Disease Analysis\n")
cat("=================================================\n\n")

# Check and install required packages
cat("Checking required packages...\n")
required_packages <- c(
  "tidyverse",
  "knitr",
  "kableExtra",
  "DescTools",
  "pwr",
  "ggplot2",
  "scales",
  "gridExtra",
  "rmarkdown"
)

new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if(length(new_packages) > 0) {
  cat("Installing missing packages:", paste(new_packages, collapse = ", "), "\n")
  install.packages(new_packages, dependencies = TRUE)
} else {
  cat("All required packages are already installed.\n")
}

# Load rmarkdown package
library(rmarkdown)

# Check if data file exists
data_path <- "Rosner_FundamentalsBiostatistics_8e_Data_Sets/ASCII-comma/HORMONE.DAT.txt"

if(file.exists(data_path)) {
  cat("\nData file found:", data_path, "\n")
} else {
  cat("\nWARNING: Data file not found at:", data_path, "\n")
  cat("Please check the data file path.\n")
}

# Render the R Markdown document
cat("\n=================================================\n")
cat("Rendering R Markdown document...\n")
cat("=================================================\n\n")

tryCatch({
  rmarkdown::render(
    input = "Chapter_10_Hepatic_Disease_Analysis.Rmd",
    output_format = "html_document",
    output_file = "Chapter_10_Hepatic_Disease_Analysis.html"
  )

  cat("\n=================================================\n")
  cat("SUCCESS!\n")
  cat("=================================================\n")
  cat("HTML document generated successfully!\n")
  cat("Output file: Chapter_10_Hepatic_Disease_Analysis.html\n")
  cat("\nYou can now open the HTML file in your web browser.\n")

}, error = function(e) {
  cat("\n=================================================\n")
  cat("ERROR!\n")
  cat("=================================================\n")
  cat("Failed to render the document.\n")
  cat("Error message:", conditionMessage(e), "\n")
  cat("\nPlease check:\n")
  cat("1. All required packages are installed\n")
  cat("2. Data file exists at the correct path\n")
  cat("3. You have write permissions in this directory\n")
})

cat("\n=================================================\n")
cat("Script completed.\n")
cat("=================================================\n")
