# ProfitGuard — E-commerce Profit Leakage Analytics

ProfitGuard is an end-to-end e-commerce analytics project designed to identify where profit is being lost across revenue, refunds, delivery performance, customer behaviour, payments, and marketing.

The project combines SQL, cloud analytics, Python statistics, hypothesis testing, machine learning, and Power BI to turn raw transactional data into business recommendations.

---

## Business Objective

The goal of ProfitGuard is to help an e-commerce business answer questions such as:

- Where is revenue being lost?
- Which products and categories generate the most refund losses?
- Are delivery delays linked to higher refund rates?
- Which customers and products contribute most to revenue?
- Which marketing channels acquire customers most efficiently?
- Can refund risk be predicted before losses occur?

---

## Tech Stack

- AWS S3
- AWS Glue
- AWS Athena
- SQL
- Python
- Pandas
- NumPy
- Matplotlib
- SciPy / Statsmodels
- Scikit-learn
- Power BI

---

## Data Pipeline

Raw CSV data was stored in Amazon S3 and catalogued using AWS Glue.

SQL analysis was performed using Amazon Athena.

The analytical workflow was:

CSV Data  
→ Amazon S3  
→ AWS Glue Data Catalog  
→ Amazon Athena  
→ SQL Analysis  
→ Python Statistics  
→ A/B-style Testing  
→ Machine Learning  
→ Power BI Dashboard  
→ Business Recommendations

---

## Dataset

The project contains 8 datasets:

| Table | Rows |
|---|---:|
| Customers | 2,000 |
| Products | 300 |
| Orders | 10,000 |
| Order Items | 20,373 |
| Payments | 10,000 |
| Refunds | 881 |
| Deliveries | 9,375 |
| Marketing | 100 |

---

## Data Quality

Data-quality checks were performed before analysis, including:

- Missing foreign keys
- Null values
- Invalid quantities
- Invalid prices
- Invalid refund values
- Referential integrity checks

One anomaly was identified during Python analysis:

> 29 orders (0.29%) contained discounts greater than their gross order value.

These rows were retained and flagged as anomalies, while net order value was floored at zero for downstream statistical and modelling analysis.

---

## SQL Analysis

The SQL analysis covered:

1. Data Quality
2. Revenue & Orders
3. Product Performance
4. Customer Analysis
5. Refund Analysis
6. Delivery Analysis
7. Payment Analysis
8. Marketing Analysis

Key SQL techniques included:

- CTEs
- Window functions
- LAG
- RANK
- CASE statements
- Aggregations
- Multi-table joins
- Date functions
- Business KPI calculations

---

## Statistical Analysis

Python was used for:

- Descriptive statistics
- Distribution analysis
- Correlation analysis
- Group comparisons
- Hypothesis testing

### Key Findings

- Net order value was right-skewed.
- Refund amounts were strongly right-skewed.
- Delivery delays were heavily concentrated around zero.
- Delivery delay had the strongest order-level relationship with refund occurrence.
- Marketing spend had a strong positive relationship with customers acquired.

---

## Hypothesis Testing

A two-proportion z-test was used to compare refund rates between late and on-time deliveries.

Results:

- Late-delivery refund rate: 24.97%
- On-time refund rate: 5.83%
- Z-statistic: 24.72
- P-value: 3.02 × 10⁻¹³⁵

The result provided strong statistical evidence that late deliveries are associated with a higher refund rate.

---

## A/B-style Analysis

An A/B-style analysis was performed to test whether higher discounts improve average net order value.

### Groups

- Control: lower-discount orders
- Treatment: higher-discount orders

### Results

- Control average net order value: £662.40
- Treatment average net order value: £647.15
- Difference: -£15.25
- Percentage change: approximately -2.3%
- P-value: 0.235

There was insufficient evidence to conclude that higher discounts improve average order value.

Because historical data was used rather than random assignment, this is presented as an A/B-style analysis rather than a true randomized experiment.

---

## Machine Learning — Refund Prediction

The machine-learning objective was to predict whether an order is likely to be refunded.

Models tested:

- Dummy baseline
- Logistic Regression
- Random Forest

### Final Model

Logistic Regression performed best.

Results:

- Precision: 0.25
- Recall: 0.51
- F1-score: 0.34
- ROC-AUC: 0.700

Random Forest performed poorly on the minority refund class.

The strongest refund-risk signals were:

- Late delivery
- Delivery delay
- Discount amount

The model is best interpreted as an early-warning screening system rather than a production-ready automated decision model.

---

## Power BI Dashboard

The dashboard contains 5 pages:

### 1. Executive Overview
- Total Orders
- Net Revenue
- Average Order Value
- Refund Rate
- Late Delivery Rate
- Repeat Customer Rate

### 2. Revenue & Product
- Monthly Net Revenue
- Revenue by Category
- Top 10 Products by Revenue

### 3. Refunds & Delivery
- Refund Rate by Delivery Type
- Delivery Status Distribution
- Average Delay by Delivery Status
- Refund Reasons

### 4. Customers
- Repeat vs One-Time Customers
- Customer Segments
- Top 10 Customers by Orders
- Customers by Acquisition Channel

### 5. Marketing
- Marketing Spend by Channel
- Customers Acquired by Channel
- Average CAC by Channel
- Monthly Marketing Spend

---

## Business Recommendations

Key recommendations include:

- Prioritise reducing late deliveries.
- Use refund-risk scoring as an early-warning system.
- Avoid assuming larger discounts improve order value.
- Investigate products and categories with high refund losses.
- Shift marketing spend toward more efficient acquisition channels.
- Treat delivery performance as a profit-protection KPI.
- Monitor top-revenue products separately.

---

## Main Business Insight

The strongest consistent finding across SQL, statistics, hypothesis testing, machine learning, and Power BI was:

> Delivery delays are strongly associated with increased refund risk.

This makes delivery performance the most important operational area for reducing refund-related profit leakage.

---

## Project Structure

```text
ProfitGuard/
│
├── data/
│   └── raw/
│
├── sql/
│   ├── 01_data_quality.sql
│   ├── 02_revenue_and_orders.sql
│   ├── 03_product_performance.sql
│   ├── 04_customer_analysis.sql
│   ├── 05_refund_analysis.sql
│   ├── 06_delivery_analysis.sql
│   ├── 07_payment_analysis.sql
│   └── 08_marketing_analysis.sql
│
├── notebooks/
│   ├── statistics_analysis.ipynb
│   ├── ab_testing.ipynb
│   └── refund_prediction.ipynb
│
├── dashboard/
│   └── ProfitGuard.pbix
│
├── 12_business_recommendations.md
│
└── README.md