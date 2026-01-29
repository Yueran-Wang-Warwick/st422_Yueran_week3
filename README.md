# ST422 Week 3: Customer Subscription Analysis

**Author:** Yueran Wang 

**Course:** ST422 Statistical Consulting  

**Date:** 28/01/2026



---



## Project Overview

This repository contains a **reproducible data analysis workflow** for analysing customer subscription data.

The goal is to characterise the customer base across three tiers (**Basic, Standard, Premium**) and evaluate key business metrics including:
* **Baseline Characteristics:** Demographics and account details (Table 1).
* **Customer Sentiment:** Net Promoter Score (NPS) analysis.
* **Retention Risk:** 90-day churn rate comparison.

**Key Feature:** The code is designed to be **robust to dataset updates**. It works seamlessly with version 1 (MVP), version 2, and version 3 (Enriched) of the dataset without requiring code modification.



---



## Repository Structure

st422-week3-yourname/
├── data/
│   ├── raw/                   # Raw input data
│   │   ├── st422_week3_subscription_v1.csv
│   │   ├── st422_week3_subscription_v2.csv
│   │   └── st422_week3_subscription_v3.csv
├── outputs/
│   ├── tables/                # Generated summary tables
│   └── figures/               # Generated plots
├── reports/
│   ├── reports.Rmd            # Final analytical report
│   └── reports.html           # Rendered HTML file
├── src/
│   ├── make_table1.R          # Script to generate Table 1
│   └── make_figures.R         # Script to generate Figures 1 & 2
├── .gitignore                 # Files to ignore (e.g., system files)
├── ST422_week3.Rproj          # RStudio Project file
├── renv.lock                  # Exact package versions for reproducibility
└── README.md                  # This file

---



##  Prerequisites & Installation

To reproduce this analysis, you need:
* **R** (version 4.0 or higher)
* **RStudio**



#### Step 1: Clone and Open
1.  Clone this repository to your local machine.
2.  Open the \`ST422_week3.Rproj\` file in RStudio.



#### Step 2: Restore Environment (renv)
This project uses \`renv\` to manage dependencies (e.g., \`dplyr\`, \`ggplot2\`, \`kableExtra\`).
Run the following command in the RStudio Console to install the exact package versions used in this analysis:

```R
renv::restore()
```

*Note: If prompted, choose "y" to proceed with installation.*



---



## How to Reproduce (Robust to dataset updates)

Follow these steps to generate the analysis outputs from scratch.

#### Generate Table 1 (for st422_week3_subscription_v3)
Run the following script to create the baseline characteristics table:

```R
# For v3
input_file <- "data/raw/st422_week3_subscription_v3.csv"
source("src/make_table1.R")

# For v2 (you only need to change the file name, v1 is similar)
input_file <- "data/raw/st422_week3_subscription_v2.csv"
source("src/make_table1.R")
```

* **Input:** data/raw/st422_week3_subscription_v1.csv
* **Output:** outputs/tables/table1.png



#### Generate Visualizations (for st422_week3_subscription_v3)

Run the following script to create the NPS and Churn charts:

```R
# For v3
input_file <- "data/raw/st422_week3_subscription_v3.csv"
source("src/make_figures.R")

# For v2 (you only need to change the file name, v1 is similar)
input_file <- "data/raw/st422_week3_subscription_v2.csv"
source("src/make_figures.R")
```

* **Input:** data/raw/st422_week3_subscription_v3.csv
* **Output:** outputs/figures/figure1_nps_boxplot.jpg
* **Output:** outputs/figures/figure2_churn_barplot.jpg



---



## Expected Outputs

After running the scripts, verify that the following files exist:

| File Name                     | Location        | Description                                                  |
| :---------------------------- | :-------------- | :----------------------------------------------------------- |
| **table1.png**                | outputs/tables  | Stratified summary of customer characteristics (Median/IQR for continuous, n/% for categorical). |
| **figure1_nps_boxplot.jpg**   | outputs/figures | Boxplot of NPS scores by plan type (shows satisfaction distribution). |
| **figure2_churn_barplot.jpg** | outputs/figures | 100% Stacked bar chart showing churn rates by plan type.     |

