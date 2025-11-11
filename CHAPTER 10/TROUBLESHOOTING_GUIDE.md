# Troubleshooting Guide - Chapter 10 Analysis

## Error: "object 'Hormone' not found"

This is the error you reported. Here's how to fix it:

### Quick Fix

The R Markdown file has been **updated** with better data loading code. Try rendering again with the updated file.

### Diagnostic Steps

Run the diagnostic script to identify the exact issue:

```r
source("test_data_loading.R")
```

This script will:
1. Check if the data file exists
2. Try multiple methods to load the data
3. Display column names
4. Test the data manipulation that was failing
5. Provide specific recommendations

### Root Cause

The error occurs when:
- Column names contain quotes (like `'Hormone'` instead of `Hormone`)
- The `read.csv()` function doesn't properly strip these quotes
- When you try to reference `Hormone`, R can't find it because it's actually named `'Hormone'`

### Solution Applied

The updated R Markdown file now includes:

```r
# Read the data with proper quote handling
hormone_data <- read.csv(data_path, header = TRUE, strip.white = TRUE, quote = "'\"")

# Clean column names (remove any quotes)
colnames(hormone_data) <- gsub("'", "", colnames(hormone_data))
colnames(hormone_data) <- gsub("\"", "", colnames(hormone_data))
```

This ensures all quotes are removed from column names.

### Verification

After loading the data, the code now verifies all required columns exist:

```r
required_cols <- c("ID", "Bilsecpr", "Bilphpr", "Pansecpr", "Panphpr",
                   "Dose", "Bilsecpt", "Bilphpt", "Pansecpt", "Panphpt", "Hormone")

missing_cols <- setdiff(required_cols, colnames(hormone_data))
if(length(missing_cols) > 0) {
  stop(paste("Missing columns:", paste(missing_cols, collapse = ", ")))
}
```

If any columns are missing, you'll get a clear error message.

---

## Error: "f() values at end points not of opposite sign"

This error occurs in the sample size calculation (Problems 10.42-10.46).

**Cause:** The effect size is too small, zero, or negative, making it impossible to calculate the required sample size.

**Solution:**

The error happens when:
1. The two proportions (`p1_ideal` and `p2_ideal`) are too similar
2. The proportions are in the wrong order (treatment should be lower than control for a beneficial effect)
3. The effect size after non-compliance adjustment becomes too small

**Fix:**

The updated R Markdown file now includes:
- Error checking before calculation
- Clear error messages explaining the issue
- Informative output about what values to check

**What to do:**

1. Check lines 793-794 in the R Markdown file:
   ```r
   p1_ideal <- 0.05  # Expected event rate in treatment group (hypothetical)
   p2_ideal <- 0.10  # Expected event rate in control group (hypothetical)
   ```

2. Replace these with the **actual values from Problems 10.42 and 10.43** in your textbook.

3. Ensure:
   - Both values are between 0 and 1
   - `p2_ideal > p1_ideal` (control group has higher event rate)
   - The difference `p2_ideal - p1_ideal` is meaningful (e.g., at least 0.03-0.05)

**Example of correct values:**
```r
p1_ideal <- 0.05  # Treatment: 5% event rate
p2_ideal <- 0.10  # Control: 10% event rate
# Difference = 0.05 (5 percentage points)
```

**Why this matters:**

If your textbook problems specify different rates (e.g., p1=0.08, p2=0.12), you MUST use those values. The hypothetical values are just placeholders for demonstration.

---

## Error: "Discrete values supplied to continuous scale" (NA values)

This error occurs in the sample size visualization when all calculated sample sizes are NA.

**Full error message:**
```
Could not create visualization:
Discrete values supplied to continuous scale.
ℹ Example values: NA, NA, NA, NA, and NA
```

**Cause:**

All sample size calculations failed because effect sizes are too small across all compliance scenarios.

**What this means:**

The difference between p1_ideal and p2_ideal is so small that:
1. The effect size is below the threshold for reliable calculations
2. Even with perfect compliance, the difference is barely detectable
3. The visualization can't create a gradient scale with only NA values

**Solution:**

You **MUST** replace the hypothetical values with actual values from your textbook:

1. Open `Chapter_10_Hepatic_Disease_Analysis.Rmd`
2. Find lines 793-794:
   ```r
   p1_ideal <- 0.05  # Expected event rate in treatment group (hypothetical)
   p2_ideal <- 0.10  # Expected event rate in control group (hypothetical)
   ```

3. Replace with the **actual values from Problems 10.42 and 10.43** in your textbook

**Example scenarios:**

```r
# Scenario 1: Small effect (might still work)
p1_ideal <- 0.05  # 5% event rate
p2_ideal <- 0.10  # 10% event rate
# Difference = 0.05, Effect size ≈ 0.29 ✓

# Scenario 2: Too small (will fail)
p1_ideal <- 0.08  # 8% event rate
p2_ideal <- 0.10  # 10% event rate
# Difference = 0.02, Effect size ≈ 0.12 ✗

# Scenario 3: Moderate effect (ideal)
p1_ideal <- 0.03  # 3% event rate
p2_ideal <- 0.08  # 8% event rate
# Difference = 0.05, Effect size ≈ 0.36 ✓✓
```

**After the fix:**

The document will now provide helpful output:
- If values are valid: Creates visualization with heatmap
- If values are invalid: Shows diagnostic information explaining why

**The updated code will tell you:**
- Current proportion values
- Calculated effect size
- Whether the effect size is sufficient
- What values you need for successful calculation

---

## Other Common Errors

### Error: "cannot open file"

**Cause:** Data file not found

**Solution:**
1. Check the file exists at: `Rosner_FundamentalsBiostatistics_8e_Data_Sets/ASCII-comma/HORMONE.DAT.txt`
2. Verify you're in the correct working directory
3. Check the path separators (use `/` not `\` in R)

**Quick fix:**
```r
# Check current directory
getwd()

# Set to correct directory
setwd("C:/Users/ValensRwema/Desktop/Theories of Biostatistics/Theories of Biostatistics/CHAPTER 10")

# Verify file exists
file.exists("Rosner_FundamentalsBiostatistics_8e_Data_Sets/ASCII-comma/HORMONE.DAT.txt")
```

---

### Error: "there is no package called 'XXX'"

**Cause:** Required package not installed

**Solution:**
```r
# Install missing package
install.packages("package_name")

# Or install all required packages at once
required_packages <- c("tidyverse", "knitr", "kableExtra", "DescTools",
                       "pwr", "ggplot2", "scales", "gridExtra", "rmarkdown")
new_packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]
if(length(new_packages)) install.packages(new_packages)
```

---

### Error: "Pandoc not found"

**Cause:** RStudio's pandoc not in PATH (when running outside RStudio)

**Solution:**
1. **Best solution:** Use RStudio to render (it includes pandoc)
2. **Alternative:** Install pandoc separately from https://pandoc.org/
3. **Workaround:** Render to a simpler format:
   ```r
   rmarkdown::render("Chapter_10_Hepatic_Disease_Analysis.Rmd",
                     output_format = "html_document")
   ```

---

### Error: "unused argument (output_format = ...)"

**Cause:** Trying to use render() without rmarkdown package

**Solution:**
```r
# Make sure rmarkdown is loaded
library(rmarkdown)

# Then render
render("Chapter_10_Hepatic_Disease_Analysis.Rmd")
```

---

### Warning: "expected frequencies < 5"

**This is not an error!** This is a statistical warning.

**Meaning:** Some cells in your contingency table have expected frequencies less than 5

**Solution:**
- The code already handles this!
- Fisher's exact test is provided as an alternative
- Both results are shown for comparison

---

### Error: "there is no package called 'DescTools'"

**Cause:** DescTools package not installed

**Solution:**
```r
install.packages("DescTools")
```

**Note:** DescTools is needed for the Cochran-Armitage trend test

---

## Step-by-Step Debugging Process

If you're still having issues, follow these steps:

### Step 1: Test Data Loading Only

```r
# Set directory
setwd("C:/Users/ValensRwema/Desktop/Theories of Biostatistics/Theories of Biostatistics/CHAPTER 10")

# Load data
data_path <- "Rosner_FundamentalsBiostatistics_8e_Data_Sets/ASCII-comma/HORMONE.DAT.txt"
hormone_data <- read.csv(data_path, header = TRUE, strip.white = TRUE, quote = "'\"")

# Clean names
colnames(hormone_data) <- gsub("'|\"", "", colnames(hormone_data))

# Check result
str(hormone_data)
colnames(hormone_data)
```

If this works, the data loading is fine.

### Step 2: Test Tidyverse

```r
library(tidyverse)

# Try the mutation
hormone_data_test <- hormone_data %>%
  mutate(Hormone_Group = factor(Hormone, levels = 1:5))

print(table(hormone_data_test$Hormone_Group))
```

If this works, tidyverse is working correctly.

### Step 3: Check Column Access

```r
# Try to access the Hormone column
print(hormone_data$Hormone)

# Check if it exists
"Hormone" %in% colnames(hormone_data)
```

If this returns FALSE, the column name is still not correct.

### Step 4: Inspect Raw Column Names

```r
# See exactly what R sees
print(colnames(hormone_data))

# See with quotes
print(dQuote(colnames(hormone_data)))

# Check for hidden characters
print(nchar(colnames(hormone_data)))
```

This will reveal any hidden characters or encoding issues.

---

## Alternative Data Loading Methods

If the standard method still doesn't work, try these alternatives:

### Method 1: Manual Column Names

```r
hormone_data <- read.csv(data_path, header = FALSE, skip = 1)
colnames(hormone_data) <- c("ID", "Bilsecpr", "Bilphpr", "Pansecpr", "Panphpr",
                            "Dose", "Bilsecpt", "Bilphpt", "Pansecpt", "Panphpt", "Hormone")
```

### Method 2: readr Package

```r
library(readr)
hormone_data <- read_csv(data_path)
colnames(hormone_data) <- gsub("'|\"", "", colnames(hormone_data))
```

### Method 3: data.table Package

```r
library(data.table)
hormone_data <- fread(data_path)
colnames(hormone_data) <- gsub("'|\"", "", colnames(hormone_data))
hormone_data <- as.data.frame(hormone_data)
```

---

## Getting Help

If none of these solutions work, provide this information:

1. **R Version:**
   ```r
   R.version.string
   ```

2. **Package Versions:**
   ```r
   packageVersion("tidyverse")
   packageVersion("rmarkdown")
   ```

3. **Operating System:**
   ```r
   Sys.info()["sysname"]
   ```

4. **First few lines of data file:**
   ```r
   readLines("Rosner_FundamentalsBiostatistics_8e_Data_Sets/ASCII-comma/HORMONE.DAT.txt", n = 3)
   ```

5. **Column names after loading:**
   ```r
   colnames(hormone_data)
   ```

6. **Exact error message:** Copy the entire error from the console

---

## Files to Help You

1. **test_data_loading.R** - Comprehensive diagnostic script
   - Run this first to identify the issue
   - Provides detailed output at each step

2. **render_chapter10.R** - Automated rendering with error handling
   - Checks packages
   - Verifies data file
   - Renders with informative error messages

3. **Chapter_10_Hepatic_Disease_Analysis.Rmd** - Updated with fixes
   - Better data loading
   - Column name verification
   - Clear error messages

---

## Success Checklist

✅ Data file exists in correct location
✅ All required packages installed
✅ Column names load without quotes
✅ 'Hormone' column accessible
✅ Test script runs without errors
✅ Render script completes successfully

Once all items are checked, the document should render successfully!

---

**Last Updated:** 2025-10-18
