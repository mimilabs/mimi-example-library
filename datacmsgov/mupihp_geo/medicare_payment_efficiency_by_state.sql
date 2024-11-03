-- medicare_payment_efficiency.sql

-- Business Purpose:
-- Analyze Medicare payment efficiency by calculating the ratio of average Medicare payments
-- to total payments across states for high-volume DRGs. This helps identify:
-- 1. States with optimal Medicare payment capture
-- 2. Opportunities to improve payment efficiency
-- 3. Patterns in Medicare vs non-Medicare payment mix
-- Understanding these patterns can inform revenue cycle strategies and payer contract negotiations.

WITH high_volume_drgs AS (
  -- Identify DRGs with significant volume for meaningful analysis
  SELECT drg_cd, drg_desc
  FROM mimi_ws_1.datacmsgov.mupihp_geo
  WHERE mimi_src_file_date = '2022-12-31'
    AND rndrng_prvdr_geo_lvl = 'National' 
    AND tot_dschrgs > 10000
),

state_payments AS (
  -- Calculate payment ratios and volumes by state for high-volume DRGs
  SELECT 
    g.rndrng_prvdr_geo_desc AS state,
    g.drg_cd,
    g.drg_desc,
    g.tot_dschrgs,
    g.avg_mdcr_pymt_amt,
    g.avg_tot_pymt_amt,
    ROUND(g.avg_mdcr_pymt_amt / g.avg_tot_pymt_amt * 100, 2) as medicare_payment_ratio
  FROM mimi_ws_1.datacmsgov.mupihp_geo g
  INNER JOIN high_volume_drgs h 
    ON g.drg_cd = h.drg_cd
  WHERE g.mimi_src_file_date = '2022-12-31'
    AND g.rndrng_prvdr_geo_lvl = 'State'
)

-- Final output showing payment efficiency metrics
SELECT 
  state,
  COUNT(DISTINCT drg_cd) as drg_count,
  SUM(tot_dschrgs) as total_discharges,
  ROUND(AVG(medicare_payment_ratio), 2) as avg_medicare_ratio,
  ROUND(MIN(medicare_payment_ratio), 2) as min_medicare_ratio,
  ROUND(MAX(medicare_payment_ratio), 2) as max_medicare_ratio
FROM state_payments
GROUP BY state
ORDER BY avg_medicare_ratio DESC;

-- How it works:
-- 1. First CTE identifies high-volume DRGs nationally to focus on meaningful cases
-- 2. Second CTE calculates Medicare payment ratios for these DRGs at state level
-- 3. Final query aggregates metrics by state to show payment efficiency patterns

-- Assumptions and Limitations:
-- 1. Uses 2022 data - adjust date parameter for other years
-- 2. 10,000 discharge threshold for high volume - adjust as needed
-- 3. Medicare payment ratio may be affected by factors beyond efficiency
-- 4. State-level aggregation masks facility-specific variations
-- 5. Does not account for case mix complexity differences between states

-- Possible Extensions:
-- 1. Add year-over-year trend analysis of payment ratios
-- 2. Break down by specific DRG service lines
-- 3. Correlate with quality metrics or readmission rates
-- 4. Add demographic factors like Medicare population percentage
-- 5. Compare against state-specific cost of living indices
-- 6. Include analysis of outlier payments impact

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T14:06:16.310188
    - Additional Notes: Query focuses on Medicare payment capture efficiency at the state level for high-volume DRGs (>10,000 discharges). The ratio analysis helps identify states with optimal Medicare payment patterns and potential areas for improvement in payment collection. Note that the 10,000 discharge threshold may need adjustment for different analysis purposes, and results should be interpreted considering state-specific factors like cost of living and patient demographics.
    
    */