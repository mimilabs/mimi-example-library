-- state_drg_reimbursement_variation.sql

-- Business Purpose:
-- Analyze state-level variations in Medicare reimbursement rates relative to submitted charges
-- to identify potential underpayment/overpayment patterns and benchmark performance.
-- This analysis helps healthcare organizations understand payment efficiency and negotiate 
-- more effectively with commercial payers using Medicare as a benchmark.

WITH recent_year AS (
  SELECT MAX(SUBSTR(mimi_src_file_date, 1, 4)) as max_year
  FROM mimi_ws_1.datacmsgov.mupihp_geo
),

state_metrics AS (
  SELECT 
    rndrng_prvdr_geo_desc as state,
    COUNT(DISTINCT drg_cd) as unique_drgs,
    SUM(tot_dschrgs) as total_discharges,
    AVG(avg_tot_pymt_amt/avg_submtd_cvrd_chrg) as avg_payment_ratio,
    SUM(tot_dschrgs * avg_tot_pymt_amt)/SUM(tot_dschrgs) as case_mix_adjusted_payment
  FROM mimi_ws_1.datacmsgov.mupihp_geo
  WHERE rndrng_prvdr_geo_lvl = 'State'
    AND SUBSTR(mimi_src_file_date, 1, 4) = (SELECT max_year FROM recent_year)
  GROUP BY rndrng_prvdr_geo_desc
),

median_payment AS (
  SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY case_mix_adjusted_payment) as median_payment
  FROM state_metrics
)

SELECT 
  state,
  unique_drgs,
  total_discharges,
  ROUND(avg_payment_ratio * 100, 1) as payment_to_charge_ratio,
  ROUND(case_mix_adjusted_payment, 0) as risk_adjusted_payment_per_case,
  -- Calculate percentage difference from national median
  ROUND(((case_mix_adjusted_payment / 
    (SELECT median_payment FROM median_payment) - 1) * 100), 1) 
    as pct_diff_from_median
FROM state_metrics
ORDER BY case_mix_adjusted_payment DESC;

-- How it works:
-- 1. Identifies most recent year of data
-- 2. Calculates key metrics for each state:
--    - Number of unique DRGs (service breadth)
--    - Total discharge volume
--    - Average payment-to-charge ratio
--    - Case-mix adjusted average payment
-- 3. Calculates national median payment in separate CTE
-- 4. Compares each state's case-mix adjusted payment to national median
-- 5. Orders results by payment level to highlight variation

-- Assumptions & Limitations:
-- - Uses most recent year only - trends not captured
-- - Case-mix adjustment is simplified, using volume weighting
-- - Does not account for regional cost differences
-- - Medicare-only view may not reflect commercial patterns

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Break out by major service lines (MDC groups)
-- 3. Incorporate cost-of-living adjustments
-- 4. Add quality metrics to create value analysis
-- 5. Compare commercial payment benchmarks where available
-- 6. Include wage index adjustments for more accurate comparison

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:22:55.805200
    - Additional Notes: Analysis focuses on payment efficiency metrics by state, showing variations in Medicare reimbursement patterns. Key metrics include payment-to-charge ratios and case-mix adjusted payments, with comparisons to national medians. The query automatically uses the most recent year of data available in the dataset.
    
    */