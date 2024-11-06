-- medicare_outpatient_diagnosis_patterns.sql

-- Business Purpose:
-- Analyze patterns in primary diagnoses for Medicare outpatient claims to:
-- 1. Identify most common conditions requiring outpatient care
-- 2. Track total payments and charges by diagnosis
-- 3. Support care management and resource allocation decisions
-- 4. Provide baseline for population health analysis

WITH diagnosis_metrics AS (
    -- Aggregate key metrics by principal diagnosis
    SELECT 
        prncpal_dgns_cd,
        COUNT(DISTINCT bene_id) as unique_patients,
        COUNT(*) as total_claims,
        SUM(clm_pmt_amt) as total_payments,
        SUM(clm_tot_chrg_amt) as total_charges,
        AVG(clm_pmt_amt) as avg_payment_per_claim,
        SUM(clm_pmt_amt)/COUNT(DISTINCT bene_id) as avg_payment_per_patient
    FROM mimi_ws_1.synmedpuf.outpatient
    WHERE prncpal_dgns_cd IS NOT NULL
    GROUP BY prncpal_dgns_cd
)

SELECT 
    d.prncpal_dgns_cd as diagnosis_code,
    d.unique_patients,
    d.total_claims,
    d.total_payments,
    d.total_charges,
    d.avg_payment_per_claim,
    d.avg_payment_per_patient,
    -- Calculate relative metrics
    ROUND(d.total_claims * 100.0 / SUM(d.total_claims) OVER(), 2) as pct_of_all_claims,
    ROUND(d.total_payments * 100.0 / SUM(d.total_payments) OVER(), 2) as pct_of_all_payments
FROM diagnosis_metrics d
WHERE d.total_claims >= 10  -- Filter out rare diagnoses
ORDER BY d.total_payments DESC
LIMIT 20;

-- How this query works:
-- 1. Creates CTE to aggregate key metrics by principal diagnosis
-- 2. Calculates per-claim and per-patient averages
-- 3. Adds relative percentages for claims and payments
-- 4. Returns top 20 diagnoses by total payments

-- Assumptions and Limitations:
-- 1. Uses principal diagnosis only, not secondary diagnoses
-- 2. Assumes diagnosis codes are valid and consistently coded
-- 3. Minimum threshold of 10 claims to filter statistical noise
-- 4. Limited to top 20 diagnoses for practical review
-- 5. Does not account for diagnosis code changes over time

-- Possible Extensions:
-- 1. Add diagnosis code descriptions lookup
-- 2. Group diagnoses by clinical categories
-- 3. Add temporal trends analysis
-- 4. Include geographic variation
-- 5. Compare against national benchmarks
-- 6. Analyze correlation with procedures
-- 7. Include patient demographics
-- 8. Add severity or risk adjustment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:13:25.939037
    - Additional Notes: This query provides a financial analysis per diagnosis code, focusing on both patient volume and cost metrics. Note that the 10-claim threshold may need adjustment based on data volume, and the top 20 limit can be modified to show more or fewer results. Consider joining with a diagnosis code reference table for more meaningful output.
    
    */