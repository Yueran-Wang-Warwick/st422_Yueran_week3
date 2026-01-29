# ==============================================================================
# Script Name: make_table1.R
# Purpose: Generate a stratified baseline characteristics table (Table 1) 
#          and save it as a PNG image.
# Robustness: Handles missing values dynamically and ignores extra columns in v3.
# ==============================================================================

# 1. Load Required Libraries
library(readr)
library(dplyr)
library(knitr)
library(kableExtra)
library(webshot2)

# 2. Define Helper Functions
# ------------------------------------------------------------------------------

# Format count and percentage: n (percentage%)
fmt_n_pct <- function(n, denom) {
  if (denom == 0) return("0 (0%)")
  sprintf("%d (%d%%)", n, round(100 * n / denom))
}

# Format Median and IQR: Median (Q1, Q3)
fmt_med_iqr <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0) return("-")
  q <- quantile(x, probs = c(0.25, 0.75), names = FALSE)
  out <- c(median(x), q[1], q[2])
  out <- format(round(out, 1), big.mark = ",", trim = TRUE, scientific = FALSE)
  sprintf("%s (%s, %s)", out[1], out[2], out[3])
}

# 3. Data Loading and Preprocessing
# ------------------------------------------------------------------------------

# Define paths (Relative paths for reproducibility)
input_file  <- "data/raw/st422_week3_subscription_v3.csv" 
output_file <- "outputs/tables/table1.png"

# Ensure output directory exists
if (!dir.exists(dirname(output_file))) {
  dir.create(dirname(output_file), recursive = TRUE)
}

message(paste("Reading data from:", input_file))
df_raw <- read_csv(input_file, show_col_types = FALSE)

# Clean data and convert to factors
df <- df_raw %>%
  mutate(
    plan_type = factor(plan_type, levels = c("Basic", "Standard", "Premium")),
    churned_90d = factor(churned_90d, levels = c(0, 1), labels = c("No", "Yes")),
    region = as.factor(region)
  )

# 4. Grouping Logic (Stratification)
# ------------------------------------------------------------------------------

group_levels <- levels(df$plan_type)
groups <- c(group_levels, "Overall")

get_group <- function(g) {
  if (g == "Overall") df else df %>% filter(plan_type == g)
}

# Calculate total N per group
Ns <- setNames(sapply(groups, function(g) nrow(get_group(g))), groups)

# 5. Statistical Analysis Logic (Dynamic Missing Handling)
# ------------------------------------------------------------------------------

# Helper: Generate a "Missing" row only if NAs exist
calc_missing_row <- function(variable_name, col_name) {
  total_missing <- sum(is.na(df[[col_name]]))
  if (total_missing == 0) {
    return(NULL) 
  }
  row_vals <- sapply(groups, function(g) {
    d <- get_group(g)
    n_miss <- sum(is.na(d[[col_name]]))
    fmt_n_pct(n_miss, Ns[g])
  })
  data.frame(Variable = paste(variable_name, "(Missing)"), as.list(row_vals), check.names=FALSE, stringsAsFactors=FALSE)
}

# Module: Categorical Variables (n, %)
analyze_categorical <- function(variable_name, col_name, level_prefix = "- ") {
  all_levels <- levels(droplevels(df[[col_name]]))
  valid_Ns <- sapply(groups, function(g) sum(!is.na(get_group(g)[[col_name]])))
  
  level_rows <- data.frame(Variable = paste0(level_prefix, all_levels), stringsAsFactors = FALSE)
  for (g in groups) {
    d <- get_group(g)
    counts <- sapply(all_levels, function(lvl) sum(d[[col_name]] == lvl, na.rm = TRUE))
    level_rows[[g]] <- fmt_n_pct(counts, valid_Ns[g])
  }
  
  missing_row <- calc_missing_row(variable_name, col_name)
  blank_vals <- setNames(rep("", length(groups)), groups)
  header_row <- data.frame(Variable = paste0(variable_name, ", n (%)"), as.list(blank_vals), check.names=FALSE, stringsAsFactors=FALSE)
  
  bind_rows(header_row, level_rows, missing_row)
}

# Module: Binary Variables (Target level only)
analyze_binary <- function(variable_name, col_name, target_level = "Yes") {
  valid_Ns <- sapply(groups, function(g) sum(!is.na(get_group(g)[[col_name]])))
  yes_vals <- sapply(groups, function(g) {
    d <- get_group(g)
    fmt_n_pct(sum(d[[col_name]] == target_level, na.rm = TRUE), valid_Ns[g])
  })
  main_row <- data.frame(Variable = paste0(variable_name, ", n (%)"), as.list(yes_vals), check.names=FALSE, stringsAsFactors=FALSE)
  missing_row <- calc_missing_row(variable_name, col_name)
  bind_rows(main_row, missing_row)
}

# Module: Continuous Variables (Median, IQR)
analyze_continuous <- function(variable_name, col_name) {
  stats_vals <- sapply(groups, function(g) {
    fmt_med_iqr(get_group(g)[[col_name]])
  })
  main_row <- data.frame(Variable = paste0(variable_name, ", median (IQR)"), as.list(stats_vals), check.names=FALSE, stringsAsFactors=FALSE)
  missing_row <- calc_missing_row(variable_name, col_name)
  bind_rows(main_row, missing_row)
}

# 6. Assembly and Rendering
# ------------------------------------------------------------------------------

# Assemble the data frame
tab_df <- bind_rows(
  analyze_categorical("Region", "region"),
  analyze_binary("Churned (90d)", "churned_90d"),
  analyze_continuous("Tenure (months)", "tenure_months"),
  analyze_continuous("Monthly Fee (GBP)", "monthly_fee_gbp"),
  analyze_continuous("NPS Score", "nps_score"),
  analyze_continuous("Support Tickets (90d)", "support_tickets_90d"),
  analyze_continuous("Last Login (days)", "last_login_days")
)

# Rename columns to include sample size (N=...)
tab_final <- tab_df %>%
  select(Variable, all_of(groups)) %>%
  rename_with(~ ifelse(.x %in% names(Ns), sprintf("%s (N=%d)", .x, Ns[.x]), .x))

# Create kable object
k_table <- kable(
  tab_final,
  caption = "Table 1. Customer characteristics by plan type (stratified)",
  booktabs = TRUE,
  align = "l"
) %>%
  kable_styling(
    full_width = FALSE, 
    latex_options = "hold_position",
    html_font = "Arial"
  ) %>%
  column_spec(1, bold = TRUE) %>%
  footnote(
    general = "Values are n (%) for categorical variables and median (IQR) for continuous variables. Missing values are reported explicitly if present.",
    general_title = "<b>Note.</b> ",
    threeparttable = TRUE,
    escape = FALSE
  )

# Save as PNG
save_kable(k_table, file = output_file, zoom = 2, density = 300)
message(paste("Table 1 successfully saved to:", output_file))
k_table