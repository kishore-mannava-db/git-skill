---
name: ey-sql-helper
description: "Common SQL patterns for financial data analysis and reporting. Use when building financial reports, performing reconciliation, calculating KPIs, or analyzing ledger data."
---

# EY SQL Helper Skill

## Overview

This skill provides SQL patterns commonly used in financial analysis, audit reporting, and accounting workflows on Databricks. Use it for building financial reports, trial balances, reconciliation queries, and KPI calculations.

## Quick Start

```sql
-- Trial balance summary
SELECT
  account_type,
  SUM(CASE WHEN entry_type = 'DEBIT' THEN amount ELSE 0 END) as total_debits,
  SUM(CASE WHEN entry_type = 'CREDIT' THEN amount ELSE 0 END) as total_credits,
  SUM(CASE WHEN entry_type = 'DEBIT' THEN amount ELSE -amount END) as net_balance
FROM catalog.schema.general_ledger
WHERE posting_date BETWEEN '2025-01-01' AND '2025-12-31'
GROUP BY account_type
ORDER BY account_type
```

## Common Patterns

### Pattern 1: Period-over-Period Comparison

```sql
-- Month-over-month revenue comparison
WITH monthly_revenue AS (
  SELECT
    DATE_TRUNC('month', transaction_date) as month,
    SUM(amount) as revenue
  FROM catalog.schema.revenue
  GROUP BY DATE_TRUNC('month', transaction_date)
)
SELECT
  month,
  revenue,
  LAG(revenue) OVER (ORDER BY month) as prev_month_revenue,
  ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0
    / LAG(revenue) OVER (ORDER BY month), 2) as mom_growth_pct
FROM monthly_revenue
ORDER BY month
```

### Pattern 2: Aging Analysis

```sql
-- Accounts receivable aging buckets
SELECT
  customer_id,
  customer_name,
  SUM(CASE WHEN DATEDIFF(CURRENT_DATE(), invoice_date) <= 30 THEN outstanding_amount ELSE 0 END) as current_0_30,
  SUM(CASE WHEN DATEDIFF(CURRENT_DATE(), invoice_date) BETWEEN 31 AND 60 THEN outstanding_amount ELSE 0 END) as past_due_31_60,
  SUM(CASE WHEN DATEDIFF(CURRENT_DATE(), invoice_date) BETWEEN 61 AND 90 THEN outstanding_amount ELSE 0 END) as past_due_61_90,
  SUM(CASE WHEN DATEDIFF(CURRENT_DATE(), invoice_date) > 90 THEN outstanding_amount ELSE 0 END) as past_due_over_90,
  SUM(outstanding_amount) as total_outstanding
FROM catalog.schema.accounts_receivable
WHERE status = 'OPEN'
GROUP BY customer_id, customer_name
ORDER BY total_outstanding DESC
```

### Pattern 3: Reconciliation Check

```sql
-- Reconcile two data sources
SELECT
  COALESCE(s.transaction_id, t.transaction_id) as transaction_id,
  s.amount as source_amount,
  t.amount as target_amount,
  ABS(COALESCE(s.amount, 0) - COALESCE(t.amount, 0)) as difference,
  CASE
    WHEN s.transaction_id IS NULL THEN 'MISSING_IN_SOURCE'
    WHEN t.transaction_id IS NULL THEN 'MISSING_IN_TARGET'
    WHEN s.amount != t.amount THEN 'AMOUNT_MISMATCH'
    ELSE 'MATCHED'
  END as match_status
FROM catalog.schema.source_data s
FULL OUTER JOIN catalog.schema.target_data t
  ON s.transaction_id = t.transaction_id
WHERE s.transaction_id IS NULL
   OR t.transaction_id IS NULL
   OR s.amount != t.amount
```

### Pattern 4: Running Balance

```sql
-- Calculate running balance for an account
SELECT
  transaction_date,
  description,
  CASE WHEN entry_type = 'DEBIT' THEN amount ELSE 0 END as debit,
  CASE WHEN entry_type = 'CREDIT' THEN amount ELSE 0 END as credit,
  SUM(CASE WHEN entry_type = 'DEBIT' THEN amount ELSE -amount END)
    OVER (PARTITION BY account_id ORDER BY transaction_date, transaction_id) as running_balance
FROM catalog.schema.general_ledger
WHERE account_id = '1000'
ORDER BY transaction_date, transaction_id
```

### Pattern 5: Top-N Analysis with Window Functions

```sql
-- Top 5 customers by revenue per region
WITH ranked AS (
  SELECT
    region,
    customer_name,
    SUM(revenue) as total_revenue,
    ROW_NUMBER() OVER (PARTITION BY region ORDER BY SUM(revenue) DESC) as rank
  FROM catalog.schema.sales
  GROUP BY region, customer_name
)
SELECT * FROM ranked WHERE rank <= 5
ORDER BY region, rank
```

## Common Issues

| Issue | Solution |
|-------|----------|
| **Precision loss in calculations** | Use `DECIMAL(18,2)` for financial amounts, avoid FLOAT |
| **Timezone issues** | Standardize to UTC, use `TIMESTAMP` not `STRING` |
| **Slow period queries** | Partition tables by date, use Z-ORDER on date columns |
| **Reconciliation gaps** | Check for duplicates and NULL keys before joining |
