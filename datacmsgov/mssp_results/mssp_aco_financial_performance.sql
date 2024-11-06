-- Medicare ACO Financial Performance Analysis
-- Purpose: Analyze key financial metrics of Medicare Shared Savings Program (MSSP) ACOs
-- to identify high-performing organizations and financial trends.
-- Business Value: Support strategic decisions for ACO investments and identify best practices.

WITH ACO_Performance AS (
    -- Get core financial metrics for each ACO
    SELECT 
        aco_name,
        aco_state,
        n_ab AS total_beneficiaries,
        ROUND(updated_bnchmk, 2) AS benchmark_pmpm,
        ROUND(per_capita_exp_total_py, 2) AS actual_cost_pmpm,
        ROUND(sav_rate * 100, 1) AS savings_rate_pct,
        ROUND(earn_save_loss/1000000, 2) AS earned_savings_millions,
        qual_score AS quality_score,
        rev_exp_cat AS revenue_category,
        current_track
    FROM mimi_ws_1.datacmsgov.mssp_results
    WHERE performance_year_end >= '2022-01-01'  -- Focus on recent performance
)

SELECT
    revenue_category,
    current_track,
    COUNT(DISTINCT aco_name) AS num_acos,
    ROUND(AVG(total_beneficiaries)) AS avg_beneficiaries,
    ROUND(AVG(benchmark_pmpm), 0) AS avg_benchmark_pmpm,
    ROUND(AVG(actual_cost_pmpm), 0) AS avg_actual_cost_pmpm,
    ROUND(AVG(savings_rate_pct), 1) AS avg_savings_rate_pct,
    ROUND(SUM(earned_savings_millions), 1) AS total_earned_savings_millions,
    ROUND(AVG(quality_score), 1) AS avg_quality_score
FROM ACO_Performance
GROUP BY revenue_category, current_track
ORDER BY revenue_category, current_track;

-- How this query works:
-- 1. Creates a CTE with key financial and operational metrics per ACO
-- 2. Aggregates results by revenue category and track to show performance patterns
-- 3. Formats monetary values in meaningful units (PMPM, millions)
-- 4. Focuses on recent performance to support current decision-making

-- Assumptions and Limitations:
-- - Recent data (2022+) is most relevant for current analysis
-- - PMPM (per member per month) costs are most comparable across ACOs
-- - Quality scores are comparable across measurement periods
-- - All financial values are in same currency units (USD)

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include geographic analysis by state/region
-- 3. Add provider composition metrics (hospitals, physicians)
-- 4. Incorporate quality measure details
-- 5. Add risk score adjustments to financial comparisons
-- 6. Create performance tiers/rankings
-- 7. Add cost category breakdowns (inpatient, outpatient, etc.)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:06:11.664400
    - Additional Notes: Query focuses on high-level ACO performance metrics and includes only recent performance years (2022+). Financial metrics are normalized to per-member-per-month (PMPM) values for comparability. The results are grouped by revenue category and track type to identify patterns in ACO performance based on organizational characteristics.
    
    */