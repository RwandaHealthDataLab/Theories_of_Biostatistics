# Chapter 10: Hepatic Disease Analysis

## Project Overview

This project contains a comprehensive statistical analysis of the Hepatic Disease study using the HORMONE.DAT dataset from Rosner's Fundamentals of Biostatistics (8th Edition).

## Files Included

1. **Chapter_10_Hepatic_Disease_Analysis.Rmd** - Main R Markdown document
2. **HORMONE.DAT.txt** - Dataset (located in `Rosner_FundamentalsBiostatistics_8e_Data_Sets/ASCII-comma/`)
3. **README_Chapter10.md** - This file

## Analysis Contents

### Problems Addressed

- **Problem 10.37**: Test procedure for comparing proportions across five treatment groups
- **Problem 10.38**: Chi-square test for pancreatic secretion increases
- **Problem 10.39**: Chi-square test for biliary secretion increases
- **Problem 10.40**: Dose-response analysis for pancreatic secretions (by hormone type)
- **Problem 10.41**: Dose-response analysis for biliary secretions (by hormone type)
- **Problems 10.42-10.46**: Sample size calculations with compliance considerations

### Statistical Methods

- Chi-square test for independence
- Fisher's exact test
- Cochran-Armitage trend test
- Power analysis for two-proportion tests
- Effect size calculations (Cohen's h)

## How to Render the Document

### Option 1: Using RStudio (Recommended)

1. Open RStudio
2. Open the file `Chapter_10_Hepatic_Disease_Analysis.Rmd`
3. Click the **"Knit"** button at the top of the editor
4. The HTML output will be generated automatically

### Option 2: Using R Console

```r
# Set working directory
setwd("C:/Users/ValensRwema/Desktop/Theories of Biostatistics/Theories of Biostatistics/CHAPTER 10")

# Render the document
rmarkdown::render("Chapter_10_Hepatic_Disease_Analysis.Rmd")
```

### Option 3: Using Command Line (if R is in PATH)

```bash
cd "C:\Users\ValensRwema\Desktop\Theories of Biostatistics\Theories of Biostatistics\CHAPTER 10"
Rscript -e "rmarkdown::render('Chapter_10_Hepatic_Disease_Analysis.Rmd')"
```

## Required R Packages

Before rendering, ensure the following packages are installed:

```r
install.packages(c(
  "tidyverse",
  "knitr",
  "kableExtra",
  "DescTools",
  "pwr",
  "ggplot2",
  "scales",
  "gridExtra",
  "rmarkdown"
))
```

## Dataset Information

### Variables in HORMONE.DAT

| Variable | Description |
|----------|-------------|
| ID | Hen identification number |
| Bilsecpr | Biliary secretion pre-treatment (μL/10 min) |
| Bilphpr | Biliary pH pre-treatment |
| Pansecpr | Pancreatic secretion pre-treatment (μL/10 min) |
| Panphpr | Pancreatic pH pre-treatment |
| Dose | Hormone dose (μg/kg body weight) |
| Bilsecpt | Biliary secretion post-treatment (μL/10 min) |
| Bilphpt | Biliary pH post-treatment |
| Pansecpt | Pancreatic secretion post-treatment (μL/10 min) |
| Panphpt | Pancreatic pH post-treatment |
| Hormone | Hormone group (1-5) |

### Hormone Groups

1. **Saline (Control)**
2. **Secretin**
3. **Cholecystokinin (CCK)**
4. **Gastrin**
5. **CCK + Secretin**

## Expected Outputs

The rendered HTML document includes:

1. Data exploration and summary statistics
2. Contingency tables for all comparisons
3. Chi-square test results with p-values
4. Fisher's exact test results
5. Cochran-Armitage trend test results for dose-response
6. Multiple visualizations:
   - Bar charts of secretion increase percentages
   - Box plots of secretion changes
   - Dose-response scatter plots with trend lines
   - Heatmap of sample size requirements
7. Comprehensive interpretations and conclusions

## Troubleshooting

### If packages are missing:
```r
# Install all required packages
required_packages <- c("tidyverse", "knitr", "kableExtra", "DescTools",
                       "pwr", "ggplot2", "scales", "gridExtra", "rmarkdown")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
```

### If data file is not found:
- Ensure the data file path is correct in the Rmd file
- The default path is: `Rosner_FundamentalsBiostatistics_8e_Data_Sets/ASCII-comma/HORMONE.DAT.txt`
- Modify the path in the code chunk labeled `load-data` if necessary

### If rendering fails:
1. Check that all packages are installed
2. Verify the data file exists at the specified path
3. Ensure you have write permissions in the directory
4. Try rendering to a different format: `output_format = 'pdf_document'` or `'word_document'`

## Results Summary

The analysis examines:

1. **Overall treatment effects**: Whether different hormone treatments produce different rates of secretion increases
2. **Dose-response relationships**: Whether higher doses produce higher response rates within each hormone type
3. **Sample size planning**: How non-compliance affects study power and required sample sizes

## Notes

- The sample size calculations (Problems 10.42-10.46) use hypothetical values for demonstration purposes.
- Replace `p1_ideal` and `p2_ideal` in the code with actual values from your textbook if they differ.
- All statistical tests use α = 0.05 significance level unless otherwise specified.

## Contact

For questions about this analysis, refer to Rosner's Fundamentals of Biostatistics (8th Edition), Chapter 10.

---
Generated: `r Sys.Date()`
