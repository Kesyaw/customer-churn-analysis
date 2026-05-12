-- ============================================================
-- 1. Churn rate keseluruhan
-- ============================================================
SELECT
    COUNT(*)                                         AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    SUM(CASE WHEN Churn = 'No'  THEN 1 ELSE 0 END) AS retained,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    )                                                AS churn_rate_pct
FROM telco_churn;

-- ============================================================
-- 2. Churn rate by contract type
-- ============================================================
SELECT
    Contract,
    COUNT(*)                                         AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    )                                                AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2)                   AS avg_monthly_charges
FROM telco_churn
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- ============================================================
-- 3. Churn rate by tenure group
-- ============================================================
SELECT
    CASE
        WHEN tenure BETWEEN 0  AND 12 THEN '0-12 months'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 months'
        WHEN tenure BETWEEN 49 AND 72 THEN '49-72 months'
    END                                              AS tenure_group,
    COUNT(*)                                         AS total_customers,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    )                                                AS churn_rate_pct
FROM telco_churn
GROUP BY tenure_group
ORDER BY MIN(tenure);

-- ============================================================
-- 4. Revenue at risk per contract type
-- ============================================================
SELECT
    Contract,
    SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END)  AS revenue_lost_monthly,
    SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END)
        * 12                                                       AS revenue_lost_annually,
    COUNT(CASE WHEN Churn = 'Yes' THEN 1 END)                    AS churned_customers
FROM telco_churn
GROUP BY Contract
ORDER BY revenue_lost_monthly DESC;


-- ============================================================
-- 5. Multi-factor analysis: contract + payment method
-- ============================================================
SELECT
    Contract,
    PaymentMethod,
    COUNT(*)                                         AS total,
    SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) AS churned,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1
    )                                                AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2)                   AS avg_charges
FROM telco_churn
GROUP BY Contract, PaymentMethod
HAVING COUNT(*) > 50
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- 6. Service impact analysis
-- ============================================================
SELECT
    OnlineSecurity,
    TechSupport,
    COUNT(*)                                         AS total,
    ROUND(
        100.0 * SUM(CASE WHEN Churn = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 1
    )                                                AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2)                   AS avg_charges
FROM telco_churn
WHERE OnlineSecurity IN ('Yes', 'No')
  AND TechSupport IN ('Yes', 'No')
GROUP BY OnlineSecurity, TechSupport
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- 7. Window function: rank customer by risk per contract
-- ============================================================
WITH risk_scored AS (
    SELECT
        customerID,
        Contract,
        tenure,
        MonthlyCharges,
        Churn,
        CASE WHEN Contract = 'Month-to-month' THEN 3 ELSE 0 END +
        CASE WHEN tenure <= 12               THEN 3 ELSE 0 END +
        CASE WHEN PaymentMethod = 'Electronic check' THEN 2 ELSE 0 END +
        CASE WHEN OnlineSecurity = 'No'      THEN 1 ELSE 0 END +
        CASE WHEN TechSupport = 'No'         THEN 1 ELSE 0 END AS risk_score
    FROM telco_churn
)
SELECT
    customerID,
    Contract,
    tenure,
    MonthlyCharges,
    Churn,
    risk_score,
    RANK() OVER (PARTITION BY Contract ORDER BY risk_score DESC) AS rank_within_contract,
    ROUND(AVG(risk_score) OVER (PARTITION BY Contract), 2)      AS avg_risk_by_contract
FROM risk_scored
ORDER BY risk_score DESC;


-- ============================================================
-- 8. Retention opportunity: high-risk tapi belum churn
-- ============================================================
WITH risk_scored AS (
    SELECT
        customerID,
        tenure,
        Contract,
        MonthlyCharges,
        PaymentMethod,
        OnlineSecurity,
        TechSupport,
        Churn,
        CASE WHEN Contract = 'Month-to-month' THEN 3 ELSE 0 END +
        CASE WHEN tenure <= 12               THEN 3 ELSE 0 END +
        CASE WHEN PaymentMethod = 'Electronic check' THEN 2 ELSE 0 END +
        CASE WHEN OnlineSecurity = 'No'      THEN 1 ELSE 0 END +
        CASE WHEN TechSupport = 'No'         THEN 1 ELSE 0 END AS risk_score
    FROM telco_churn
)
SELECT
    customerID,
    tenure,
    Contract,
    MonthlyCharges,
    risk_score,
    'Priority Retention Target' AS action
FROM risk_scored
WHERE risk_score >= 6
  AND Churn = 'No'
ORDER BY MonthlyCharges DESC
LIMIT 50;
