# Simple test script to check SEXRAT data loading
library(tidyverse)

# Read the data
sexrat_data <- read.csv("../SEXRAT.DAT.txt",
                        check.names = FALSE,
                        stringsAsFactors = FALSE,
                        na.strings = c("", "NA"))

# Remove quotes from column names
colnames(sexrat_data) <- gsub("'", "", colnames(sexrat_data))

cat("=== RAW DATA ===\n")
cat("First 5 rows:\n")
print(head(sexrat_data, 5))
cat("\nColumn names:\n")
print(colnames(sexrat_data))
cat("\nUnique sx_1 values:\n")
print(unique(sexrat_data$sx_1))
cat("\nClass of sx_1:\n")
print(class(sexrat_data$sx_1))

# Clean the data
sexrat_clean <- sexrat_data %>%
  mutate(
    sx_1 = toupper(trimws(as.character(sx_1))),
    sx_2 = toupper(trimws(as.character(sx_2))),
    sx_3 = toupper(trimws(as.character(sx_3))),
    sx_1 = ifelse(sx_1 == "", NA_character_, sx_1),
    sx_2 = ifelse(sx_2 == "", NA_character_, sx_2),
    sx_3 = ifelse(sx_3 == "", NA_character_, sx_3)
  )

cat("\n=== AFTER CLEANING ===\n")
cat("First 5 rows:\n")
print(head(sexrat_clean[, c("nm_chld", "sx_1", "sx_2", "sx_3", "num_fam")], 5))
cat("\nUnique sx_1 values after cleaning:\n")
print(unique(sexrat_clean$sx_1))

# Expand the data
expanded_data <- sexrat_clean %>%
  uncount(num_fam) %>%
  mutate(family_id = row_number())

cat("\n=== AFTER EXPANSION ===\n")
cat("Total rows:", nrow(expanded_data), "\n")
cat("First 10 sx_1 values:\n")
print(head(expanded_data$sx_1, 10))
cat("\nUnique sx_1 values:\n")
print(unique(expanded_data$sx_1))
cat("\nTable of sx_1:\n")
print(table(expanded_data$sx_1, useNA = "always"))

# Filter for 2+ children
families_2plus <- expanded_data %>%
  filter(nm_chld >= 2)

cat("\n=== FAMILIES WITH 2+ CHILDREN ===\n")
cat("Total:", nrow(families_2plus), "\n")
cat("Unique sx_1:\n")
print(unique(families_2plus$sx_1))
cat("\nTable of sx_1:\n")
print(table(families_2plus$sx_1, useNA = "always"))

# Try filtering
male_first <- families_2plus %>% filter(sx_1 == "M")
female_first <- families_2plus %>% filter(sx_1 == "F")

cat("\n=== FILTERING RESULTS ===\n")
cat("Male first (sx_1 == 'M'):", nrow(male_first), "\n")
cat("Female first (sx_1 == 'F'):", nrow(female_first), "\n")
