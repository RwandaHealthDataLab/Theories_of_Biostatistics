# Run Bone Density Twin Analysis
# This script executes the analysis from Bone_Density_Twin_Hypothesis_Testing.Rmd

library(tidyverse)
library(knitr)

# Read the BONEDEN dataset
boneden_data <- read.csv("Rosner_FundamentalsBiostatistics_8e_Data_Sets/ASCII-comma/BONEDEN.DAT.txt",
                         check.names = FALSE,
                         stringsAsFactors = FALSE,
                         na.strings = c("", "NA"))

# Remove quotes from column names
colnames(boneden_data) <- gsub("'", "", colnames(boneden_data))

cat("Dataset Structure:\n")
str(boneden_data)

cat("\n\nKey Variable Descriptions:\n")
cat("- ID: Twin pair identification\n")
cat("- age: Age (years)\n")
cat("- zyg: Zygosity (1 = MZ monozygotic, 2 = DZ dizygotic)\n")
cat("- cur1: Current smoking Twin 1 (cigarettes/day)\n")
cat("- cur2: Current smoking Twin 2 (cigarettes/day)\n")
cat("- fn1: Femoral neck BMD Twin 1 (g/cm²)\n")
cat("- fn2: Femoral neck BMD Twin 2 (g/cm²)\n")
cat("- fs1: Femoral shaft BMD Twin 1 (g/cm²)\n")
cat("- fs2: Femoral shaft BMD Twin 2 (g/cm²)\n")

cat(sprintf("\n\nTotal twin pairs: %d\n", nrow(boneden_data)))

# Data Preparation
boneden_twins <- boneden_data %>%
  filter(!is.na(cur1) & !is.na(cur2) & !is.na(fn1) & !is.na(fn2) &
         !is.na(fs1) & !is.na(fs2)) %>%
  mutate(
    # Determine who smokes more
    heavier_smoker = ifelse(cur1 > cur2, 1,
                           ifelse(cur2 > cur1, 2, 0)),  # 0 = equal smoking
    smoking_diff = abs(cur1 - cur2),

    # BMD for heavier and lighter smoker
    heavier_fn = case_when(
      heavier_smoker == 1 ~ fn1,
      heavier_smoker == 2 ~ fn2,
      TRUE ~ NA_real_
    ),
    lighter_fn = case_when(
      heavier_smoker == 1 ~ fn2,
      heavier_smoker == 2 ~ fn1,
      TRUE ~ NA_real_
    ),
    heavier_fs = case_when(
      heavier_smoker == 1 ~ fs1,
      heavier_smoker == 2 ~ fs2,
      TRUE ~ NA_real_
    ),
    lighter_fs = case_when(
      heavier_smoker == 1 ~ fs2,
      heavier_smoker == 2 ~ fs1,
      TRUE ~ NA_real_
    ),

    # Smoking amounts for heavier and lighter
    heavier_cig = case_when(
      heavier_smoker == 1 ~ cur1,
      heavier_smoker == 2 ~ cur2,
      TRUE ~ NA_real_
    ),
    lighter_cig = case_when(
      heavier_smoker == 1 ~ cur2,
      heavier_smoker == 2 ~ cur1,
      TRUE ~ NA_real_
    ),

    # Differences (Heavier - Lighter)
    diff_fn = heavier_fn - lighter_fn,
    diff_fs = heavier_fs - lighter_fs,

    # Zygosity labels
    zygosity = factor(zyg, levels = c(1, 2),
                     labels = c("MZ (Identical)", "DZ (Fraternal)"))
  )

# Filter to pairs with discordant smoking (exclude equal smokers)
boneden_discordant <- boneden_twins %>%
  filter(heavier_smoker != 0)

cat("\n\n=== DATA PREPARATION SUMMARY ===\n\n")
cat(sprintf("Total twin pairs with complete data: %d\n", nrow(boneden_twins)))
cat(sprintf("Pairs with discordant smoking: %d\n", nrow(boneden_discordant)))
cat(sprintf("Pairs with equal smoking (excluded): %d\n",
            sum(boneden_twins$heavier_smoker == 0)))

cat("\n\nSmoking Discordance Summary:\n")
boneden_discordant %>%
  summarise(
    N = n(),
    Mean_Heavier = mean(heavier_cig, na.rm = TRUE),
    Mean_Lighter = mean(lighter_cig, na.rm = TRUE),
    Mean_Diff = mean(smoking_diff, na.rm = TRUE),
    Min_Diff = min(smoking_diff, na.rm = TRUE),
    Max_Diff = max(smoking_diff, na.rm = TRUE)
  ) %>%
  print()

cat("\n\nDistribution by Zygosity:\n")
print(table(boneden_discordant$zygosity))

# ===================================================================
# PROBLEM 7.73: FEMORAL NECK BMD
# ===================================================================

cat("\n\n" , paste(rep("=", 70), collapse=""), "\n")
cat("PROBLEM 7.73: FEMORAL NECK BMD\n")
cat(paste(rep("=", 70), collapse=""), "\n\n")

cat("RESEARCH QUESTION:\n")
cat("Are there significant differences in mean femoral neck BMD between\n")
cat("heavier-smoking and lighter-smoking twins?\n\n")

cat("HYPOTHESES:\n")
cat("H₀: μ_difference = 0 (no BMD difference between heavier/lighter smoker)\n")
cat("H₁: μ_difference ≠ 0 (BMD differs between heavier/lighter smoker)\n")
cat("Test: Paired t-test (two-sided)\n")
cat("Significance level: α = 0.05\n\n")

# Descriptive statistics
fn_desc <- boneden_discordant %>%
  summarise(
    N = n(),
    Mean_Heavier = mean(heavier_fn, na.rm = TRUE),
    SD_Heavier = sd(heavier_fn, na.rm = TRUE),
    Mean_Lighter = mean(lighter_fn, na.rm = TRUE),
    SD_Lighter = sd(lighter_fn, na.rm = TRUE),
    Mean_Diff = mean(diff_fn, na.rm = TRUE),
    SD_Diff = sd(diff_fn, na.rm = TRUE),
    SE_Diff = SD_Diff / sqrt(N)
  )

cat("DESCRIPTIVE STATISTICS:\n\n")
cat("Femoral Neck BMD (g/cm²):\n")
cat(sprintf("  Heavier Smoker:  Mean = %.4f, SD = %.4f\n",
            fn_desc$Mean_Heavier, fn_desc$SD_Heavier))
cat(sprintf("  Lighter Smoker:  Mean = %.4f, SD = %.4f\n",
            fn_desc$Mean_Lighter, fn_desc$SD_Lighter))
cat(sprintf("\nPaired Difference (Heavier - Lighter):\n"))
cat(sprintf("  Mean = %.4f g/cm²\n", fn_desc$Mean_Diff))
cat(sprintf("  SD = %.4f g/cm²\n", fn_desc$SD_Diff))
cat(sprintf("  SE = %.4f g/cm²\n", fn_desc$SE_Diff))
cat(sprintf("  N = %d pairs\n", fn_desc$N))

# Paired t-test
fn_test <- t.test(boneden_discordant$heavier_fn,
                  boneden_discordant$lighter_fn,
                  paired = TRUE,
                  alternative = "two.sided")

cat("\n\nHYPOTHESIS TEST RESULTS:\n\n")
cat(sprintf("t-statistic: %.4f\n", fn_test$statistic))
cat(sprintf("Degrees of freedom: %d\n", fn_test$parameter))
cat(sprintf("p-value: %.6f\n", fn_test$p.value))
cat(sprintf("95%% CI for difference: [%.4f, %.4f] g/cm²\n",
            fn_test$conf.int[1], fn_test$conf.int[2]))

cat("\n\nDECISION:\n")
if (fn_test$p.value < 0.05) {
  cat(sprintf("✗ p = %.6f < 0.05: REJECT H₀\n", fn_test$p.value))
  cat("✗ There IS a significant difference in femoral neck BMD\n")
  cat("   between heavier and lighter smoking twins\n\n")

  if (fn_desc$Mean_Diff < 0) {
    cat(sprintf("DIRECTION: Heavier smokers have LOWER BMD by %.4f g/cm²\n",
                abs(fn_desc$Mean_Diff)))
    cat(sprintf("           (95%% CI: [%.4f, %.4f])\n",
                fn_test$conf.int[1], fn_test$conf.int[2]))
  } else {
    cat(sprintf("DIRECTION: Heavier smokers have HIGHER BMD by %.4f g/cm²\n",
                fn_desc$Mean_Diff))
    cat(sprintf("           (95%% CI: [%.4f, %.4f])\n",
                fn_test$conf.int[1], fn_test$conf.int[2]))
  }
} else {
  cat(sprintf("✓ p = %.6f > 0.05: FAIL TO REJECT H₀\n", fn_test$p.value))
  cat("✓ NO significant difference in femoral neck BMD\n")
  cat("   between heavier and lighter smoking twins\n")
}

# Effect size (Cohen's d for paired data)
cohens_d_fn <- fn_desc$Mean_Diff / fn_desc$SD_Diff

cat(sprintf("\n\nEFFECT SIZE:\n"))
cat(sprintf("Cohen's d: %.4f\n", cohens_d_fn))
cat("Interpretation: ")
if (abs(cohens_d_fn) < 0.2) {
  cat("Negligible effect\n")
} else if (abs(cohens_d_fn) < 0.5) {
  cat("Small effect\n")
} else if (abs(cohens_d_fn) < 0.8) {
  cat("Medium effect\n")
} else {
  cat("Large effect\n")
}

# Percent difference
pct_diff_fn <- (fn_desc$Mean_Diff / fn_desc$Mean_Lighter) * 100
cat(sprintf("\nPercent difference: %.2f%%\n", pct_diff_fn))

# ===================================================================
# PROBLEM 7.74: FEMORAL SHAFT BMD
# ===================================================================

cat("\n\n" , paste(rep("=", 70), collapse=""), "\n")
cat("PROBLEM 7.74: FEMORAL SHAFT BMD\n")
cat(paste(rep("=", 70), collapse=""), "\n\n")

cat("RESEARCH QUESTION:\n")
cat("Are there significant differences in mean femoral shaft BMD between\n")
cat("heavier-smoking and lighter-smoking twins?\n\n")

cat("HYPOTHESES:\n")
cat("H₀: μ_difference = 0 (no BMD difference between heavier/lighter smoker)\n")
cat("H₁: μ_difference ≠ 0 (BMD differs between heavier/lighter smoker)\n")
cat("Test: Paired t-test (two-sided)\n")
cat("Significance level: α = 0.05\n\n")

# Descriptive statistics
fs_desc <- boneden_discordant %>%
  summarise(
    N = n(),
    Mean_Heavier = mean(heavier_fs, na.rm = TRUE),
    SD_Heavier = sd(heavier_fs, na.rm = TRUE),
    Mean_Lighter = mean(lighter_fs, na.rm = TRUE),
    SD_Lighter = sd(lighter_fs, na.rm = TRUE),
    Mean_Diff = mean(diff_fs, na.rm = TRUE),
    SD_Diff = sd(diff_fs, na.rm = TRUE),
    SE_Diff = SD_Diff / sqrt(N)
  )

cat("DESCRIPTIVE STATISTICS:\n\n")
cat("Femoral Shaft BMD (g/cm²):\n")
cat(sprintf("  Heavier Smoker:  Mean = %.4f, SD = %.4f\n",
            fs_desc$Mean_Heavier, fs_desc$SD_Heavier))
cat(sprintf("  Lighter Smoker:  Mean = %.4f, SD = %.4f\n",
            fs_desc$Mean_Lighter, fs_desc$SD_Lighter))
cat(sprintf("\nPaired Difference (Heavier - Lighter):\n"))
cat(sprintf("  Mean = %.4f g/cm²\n", fs_desc$Mean_Diff))
cat(sprintf("  SD = %.4f g/cm²\n", fs_desc$SD_Diff))
cat(sprintf("  SE = %.4f g/cm²\n", fs_desc$SE_Diff))
cat(sprintf("  N = %d pairs\n", fs_desc$N))

# Paired t-test
fs_test <- t.test(boneden_discordant$heavier_fs,
                  boneden_discordant$lighter_fs,
                  paired = TRUE,
                  alternative = "two.sided")

cat("\n\nHYPOTHESIS TEST RESULTS:\n\n")
cat(sprintf("t-statistic: %.4f\n", fs_test$statistic))
cat(sprintf("Degrees of freedom: %d\n", fs_test$parameter))
cat(sprintf("p-value: %.6f\n", fs_test$p.value))
cat(sprintf("95%% CI for difference: [%.4f, %.4f] g/cm²\n",
            fs_test$conf.int[1], fs_test$conf.int[2]))

cat("\n\nDECISION:\n")
if (fs_test$p.value < 0.05) {
  cat(sprintf("✗ p = %.6f < 0.05: REJECT H₀\n", fs_test$p.value))
  cat("✗ There IS a significant difference in femoral shaft BMD\n")
  cat("   between heavier and lighter smoking twins\n\n")

  if (fs_desc$Mean_Diff < 0) {
    cat(sprintf("DIRECTION: Heavier smokers have LOWER BMD by %.4f g/cm²\n",
                abs(fs_desc$Mean_Diff)))
    cat(sprintf("           (95%% CI: [%.4f, %.4f])\n",
                fs_test$conf.int[1], fs_test$conf.int[2]))
  } else {
    cat(sprintf("DIRECTION: Heavier smokers have HIGHER BMD by %.4f g/cm²\n",
                fs_desc$Mean_Diff))
    cat(sprintf("           (95%% CI: [%.4f, %.4f])\n",
                fs_test$conf.int[1], fs_test$conf.int[2]))
  }
} else {
  cat(sprintf("✓ p = %.6f > 0.05: FAIL TO REJECT H₀\n", fs_test$p.value))
  cat("✓ NO significant difference in femoral shaft BMD\n")
  cat("   between heavier and lighter smoking twins\n")
}

# Effect size (Cohen's d for paired data)
cohens_d_fs <- fs_desc$Mean_Diff / fs_desc$SD_Diff

cat(sprintf("\n\nEFFECT SIZE:\n"))
cat(sprintf("Cohen's d: %.4f\n", cohens_d_fs))
cat("Interpretation: ")
if (abs(cohens_d_fs) < 0.2) {
  cat("Negligible effect\n")
} else if (abs(cohens_d_fs) < 0.5) {
  cat("Small effect\n")
} else if (abs(cohens_d_fs) < 0.8) {
  cat("Medium effect\n")
} else {
  cat("Large effect\n")
}

# Percent difference
pct_diff_fs <- (fs_desc$Mean_Diff / fs_desc$Mean_Lighter) * 100
cat(sprintf("\nPercent difference: %.2f%%\n", pct_diff_fs))

# ===================================================================
# COMPREHENSIVE SUMMARY
# ===================================================================

cat("\n\n" , paste(rep("=", 70), collapse=""), "\n")
cat("COMPREHENSIVE SUMMARY: PROBLEMS 7.73-7.74\n")
cat(paste(rep("=", 70), collapse=""), "\n\n")

# Create summary table
summary_table <- data.frame(
  Anatomical_Site = c("Femoral Neck", "Femoral Shaft"),
  N_Pairs = c(fn_desc$N, fs_desc$N),
  Mean_Heavier = c(fn_desc$Mean_Heavier, fs_desc$Mean_Heavier),
  Mean_Lighter = c(fn_desc$Mean_Lighter, fs_desc$Mean_Lighter),
  Mean_Difference = c(fn_desc$Mean_Diff, fs_desc$Mean_Diff),
  CI_Lower = c(fn_test$conf.int[1], fs_test$conf.int[1]),
  CI_Upper = c(fn_test$conf.int[2], fs_test$conf.int[2]),
  t_statistic = c(fn_test$statistic, fs_test$statistic),
  p_value = c(fn_test$p.value, fs_test$p.value),
  Cohens_d = c(cohens_d_fn, cohens_d_fs),
  Pct_Diff = c(pct_diff_fn, pct_diff_fs)
) %>%
  mutate(
    Significant = ifelse(p_value < 0.05, "Yes", "No"),
    Sig_Code = ifelse(p_value < 0.001, "***",
                     ifelse(p_value < 0.01, "**",
                           ifelse(p_value < 0.05, "*", "ns")))
  )

cat("SUMMARY TABLE:\n\n")
print(summary_table, digits = 4)

cat("\n\nSignificance codes: *** p<0.001, ** p<0.01, * p<0.05, ns = not significant\n")

# ===================================================================
# FINAL CONCLUSIONS
# ===================================================================

cat("\n\n" , paste(rep("=", 70), collapse=""), "\n")
cat("FINAL CONCLUSIONS\n")
cat(paste(rep("=", 70), collapse=""), "\n\n")

cat("PROBLEM 7.73: FEMORAL NECK BMD\n")
cat(sprintf("- p-value: %.6f\n", fn_test$p.value))
if (fn_test$p.value < 0.05) {
  cat("- Decision: REJECT H₀\n")
  cat(sprintf("- Mean difference: %.4f g/cm² (95%% CI: [%.4f, %.4f])\n",
              fn_desc$Mean_Diff, fn_test$conf.int[1], fn_test$conf.int[2]))
  cat("- CONCLUSION: Heavier smoking IS associated with BMD differences\n")
} else {
  cat("- Decision: FAIL TO REJECT H₀\n")
  cat("- CONCLUSION: No significant BMD difference detected\n")
}

cat("\n\nPROBLEM 7.74: FEMORAL SHAFT BMD\n")
cat(sprintf("- p-value: %.6f\n", fs_test$p.value))
if (fs_test$p.value < 0.05) {
  cat("- Decision: REJECT H₀\n")
  cat(sprintf("- Mean difference: %.4f g/cm² (95%% CI: [%.4f, %.4f])\n",
              fs_desc$Mean_Diff, fs_test$conf.int[1], fs_test$conf.int[2]))
  cat("- CONCLUSION: Heavier smoking IS associated with BMD differences\n")
} else {
  cat("- Decision: FAIL TO REJECT H₀\n")
  cat("- CONCLUSION: No significant BMD difference detected\n")
}

cat("\n\n=====================================\n")
cat("OVERALL INTERPRETATION\n")
cat("=====================================\n\n")

n_sig <- sum(summary_table$Significant == "Yes")

if (n_sig == 2) {
  cat("✗ Both anatomical sites show SIGNIFICANT differences\n")
  cat("✗ STRONG EVIDENCE that heavier smoking affects bone density\n\n")
} else if (n_sig == 1) {
  cat("~ ONE anatomical site shows significant differences\n")
  cat("~ MODERATE EVIDENCE for smoking effects on bone density\n\n")
} else {
  cat("✓ Neither anatomical site shows significant differences\n")
  cat("✓ NO STRONG EVIDENCE for smoking effects in this twin study\n\n")
}

cat("KEY ADVANTAGES OF TWIN STUDY DESIGN:\n")
cat("- Controls for genetic factors (twins share genes)\n")
cat("- Controls for family environment and early life factors\n")
cat("- Paired design increases statistical power\n")
cat("- Isolates environmental effect of smoking\n\n")

cat("INTERPRETATION NOTES:\n")
cat("- Negative differences suggest heavier smokers have LOWER BMD\n")
cat("- This would be consistent with known harmful effects of smoking\n")
cat("- Twin studies provide strong causal evidence\n")
cat("- Effect sizes indicate clinical significance beyond statistical significance\n\n")

cat("CLINICAL IMPLICATIONS:\n")
cat("- Smoking is a modifiable risk factor for osteoporosis\n")
cat("- Even within twin pairs, smoking differences correlate with BMD\n")
cat("- Smoking cessation may help preserve bone health\n")
cat("- Twins with discordant smoking provide natural experiment\n")

cat("\n\n" , paste(rep("=", 70), collapse=""), "\n")
cat("ANALYSIS COMPLETE\n")
cat(paste(rep("=", 70), collapse=""), "\n")
