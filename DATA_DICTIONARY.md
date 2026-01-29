## Data Dictionary

**Dataset:** Subscription Customer Data
**Versions Covered:** v1, v2, v3


---



## Core Variables (Present in v1, v2, v3)

These variables are available in **all** dataset versions. The reproducible analysis pipeline (Table 1 & Figures) relies exclusively on these columns to ensure robustness.

| Variable Name           | Type        | Description                                                  |
| :---------------------- | :---------- | :----------------------------------------------------------- |
| **customer_id**         | Integer     | Unique identifier for each customer.                         |
| **signup_date**         | Date        | The date the customer originally subscribed.                 |
| **region**              | Categorical | Geographic region of the customer (e.g., North, South, Midlands). |
| **plan_type**           | Categorical | Subscription tier (**Basic**, **Standard**, **Premium**). Used for stratification. |
| **tenure_months**       | Numeric     | Number of months the customer has been subscribed.           |
| **monthly_fee_gbp**     | Numeric     | Monthly subscription fee paid by the customer (in £).        |
| **support_tickets_90d** | Numeric     | Number of support tickets raised in the last 90 days.        |
| **last_login_days**     | Numeric     | Days since the customer last logged into the platform.       |
| **nps_score**           | Numeric     | Net Promoter Score (-100 to 100). Measure of customer satisfaction. |
| **churned_90d**         | Binary      | **0** = Retained, **1** = Churned (cancelled within last 90 days). |



---



## Enriched Variables (Present in v3 only)

These variables are **only** available in the enriched dataset version (v3). They are currently **ignored** by the automated reporting pipeline to maintain backward compatibility.

| Variable Name           | Type        | Description                                                  |
| :---------------------- | :---------- | :----------------------------------------------------------- |
| **marketing_channel**   | Categorical | Acquisition channel (e.g., Social, Organic search).          |
| **device_type**         | Categorical | Primary device used (Mobile, Desktop, Tablet).               |
| **income_band**         | Categorical | Estimated annual income range of the customer.               |
| **contract_type**       | Categorical | Billing frequency (Monthly vs Annual).                       |
| **revenue_last_3m_gbp** | Numeric     | Total revenue generated from the customer in the last 3 months. |

