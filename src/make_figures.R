# ==============================================================================
# Script Name: make_figures.R
# Purpose: Generate high-quality visualizations (JPG) for business insights.
#          Figure 1: NPS Distribution (Boxplot)
#          Figure 2: Churn Rate (Stacked Bar Chart)
# Robustness: Uses only core variables; handles missing data; scales to any N.
# ==============================================================================

# 1. Load Required Libraries
library(readr)
library(dplyr)
library(ggplot2)

# 2. Setup Paths and Directories
# ------------------------------------------------------------------------------

# Input file (Configurable for v1/v2/v3)
input_file <- "data/raw/st422_week3_subscription_v3.csv"
output_dir <- "outputs/figures"

# Ensure output directory exists
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

message(paste("Reading data from:", input_file))
df_raw <- read_csv(input_file, show_col_types = FALSE)

# 3. Data Cleaning and Formatting
# ------------------------------------------------------------------------------
df <- df_raw %>%
  mutate(
    # Enforce logical order: Basic -> Standard -> Premium
    plan_type = factor(plan_type, levels = c("Basic", "Standard", "Premium")),
    # Recode churn: 0 -> Retained, 1 -> Churned
    churned_90d = factor(churned_90d, levels = c(0, 1), labels = c("Retained", "Churned"))
  )

# 4. Figure 1: NPS Satisfaction Distribution (Boxplot)
# ------------------------------------------------------------------------------
# Insight: Assess if Premium users are actually happier than Basic users.
# Robustness: Filters NAs to avoid warnings; Jitter points handle varying sample sizes.

# Remove rows with missing NPS scores
df_nps <- df %>% filter(!is.na(nps_score))

p1 <- ggplot(df_nps, aes(x = plan_type, y = nps_score, fill = plan_type)) +
  # Boxplot for statistical summary (Median + IQR)
  geom_boxplot(alpha = 0.8, outlier.shape = NA, width = 0.6) +
  # Jitter points to show actual data density
  geom_jitter(width = 0.2, alpha = 0.3, size = 1.2, color = "#333333") +
  scale_fill_brewer(palette = "Set2") +
  theme_minimal(base_size = 14) +
  labs(
    title = "Customer Satisfaction Distribution (NPS)",
    subtitle = "Are Premium users actually happier?",
    x = "Subscription Plan",
    y = "Net Promoter Score",
    caption = paste("Source:", basename(input_file))
  ) +
  theme(
    legend.position = "none",
    plot.title = element_text(face = "bold"),
    panel.grid.major.x = element_blank()
  )

# Save as JPG with white background
output_p1 <- file.path(output_dir, "figure1_nps_boxplot.jpg")
ggsave(output_p1, plot = p1, width = 8, height = 6, dpi = 300, bg = "white")
message(paste("Saved:", output_p1))

# 5. Figure 2: Churn Rate Comparison (Stacked Bar)
# ------------------------------------------------------------------------------
# Insight: Compare relative risk across plans regardless of total user count.
# Robustness: 'position = fill' ensures y-axis is always 0-100%.

# Remove rows with missing churn status
df_churn <- df %>% filter(!is.na(churned_90d))

p2 <- ggplot(df_churn, aes(x = plan_type, fill = churned_90d)) +
  # 100% Stacked Bar Chart
  geom_bar(position = "fill", width = 0.7) +
  # Custom colors: Cool for Retained, Warm/Alert for Churned
  scale_fill_manual(values = c("Retained" = "#4E79A7", "Churned" = "#E15759"), 
                    name = "Customer Status") +
  scale_y_continuous(labels = scales::percent_format()) +
  theme_minimal(base_size = 14) +
  labs(
    title = "Churn Risk by Plan Type",
    subtitle = "Proportion of customers leaving within 90 days",
    x = "Subscription Plan",
    y = "Proportion (%)",
    caption = paste("Source:", basename(input_file))
  ) +
  theme(
    plot.title = element_text(face = "bold"),
    panel.grid.major.x = element_blank(),
    legend.position = "top"
  )

# Save as JPG with white background
output_p2 <- file.path(output_dir, "figure2_churn_barplot.jpg")
ggsave(output_p2, plot = p2, width = 8, height = 6, dpi = 300, bg = "white")
message(paste("Saved:", output_p2))
print(p1)
print(p2)