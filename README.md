# Walmart Sales Analysis — Business Insights from Transaction Data

## 1. Overview
This project analyzes Walmart point‑of‑sale transactions to surface store‑level performance, customer behavior, and category profitability patterns that inform staffing, inventory, and pricing decisions. The workflow covers data cleaning with Python (Pandas), database loading, and SQL analytics focused on operational and financial questions.

## 2. Business Questions
- Store performance: Which branches lead or lag by revenue and volume, and how stable is this across time?
- Demand timing: What are the busiest days and time windows (morning/afternoon/evening) by branch for scheduling and capacity planning?
- Product economics: Which categories drive sales and profit; which show weak margins or inconsistent ratings?
- Payment mix: How do payment methods differ by branch and what are the implications for checkout capacity and transaction cost?
- Customer experience: Which category–city pairs show low ratings and need assortment or quality interventions?
- Risk signals: Which branches show year‑over‑year revenue decline and require follow‑up?

## 3. Data Cleaning (Python, Pandas)
Cleaning standardizes fields, fixes types, and engineers features used in downstream SQL:
- Remove missing values and duplicates.
- Normalize column names to lowercase.
- Convert currency strings to numeric (e.g., unit_price), then compute total_amount = unit_price × quantity.
- Persist a clean file for reproducibility and load to databases.

## 4. Database Load
The cleaned dataset is loaded into MySQL and PostgreSQL via SQLAlchemy, enabling portable SQL analytics and compatibility with common BI tools.

## 5. SQL Analysis Highlights
- Payment mix by branch and total quantity to understand throughput and cost exposure.
- Busiest weekday and time‑of‑day per branch for staffing and queue management.
- Category‑level min/max/avg ratings by city to locate quality or experience issues.
- Category sales and profit to prioritize inventory and pricing actions.
- Year‑over‑year branch revenue change to flag underperformance risks.
