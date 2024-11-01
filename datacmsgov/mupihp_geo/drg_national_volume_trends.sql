-- drg_national_trends.sql

-- Business Purpose: 
-- Analyze year-over-year trends in Medicare inpatient volumes and payments at the national level
-- to identify emerging patterns in healthcare delivery and cost dynamics.
-- This helps healthcare organizations understand macro-level shifts in inpatient utilization
-- and supports strategic planning around service line investments.

WITH recent_years AS (
  -- Get the two most recent years of data
  SELECT DISTINCT mimi_src_file_date
  FROM mimi_ws_1.datacmsgov.mupihp_geo
  ORDER BY mimi_src_file_date DESC
  LIMIT 2
),

national_drg_trends AS (
  -- Get national DRG metrics for the last 2 available years
  SELECT 
    drg_cd,
    drg_desc,
    mimi_src_file_date,
    tot_dschrgs,
    avg_tot_pymt_amt,
    tot_dschrgs * avg_tot_pymt_amt as total_payments
  FROM mimi_ws_1.datacmsgov.mupihp_geo
  WHERE rndrng_prvdr_geo_lvl = 'National'
    AND mimi_src_file_date IN (SELECT mimi_src_file_date FROM recent_years)
),

year_over_year AS (
  -- Calculate year-over-year changes
  SELECT 
    curr.drg_cd,
    curr.drg_desc,
    curr.tot_dschrgs as current_discharges,
    prev.tot_dschrgs as previous_discharges,
    ROUND(100.0 * (curr.tot_dschrgs - prev.tot_dschrgs) / prev.tot_dschrgs, 1) as discharge_growth_pct,
    curr.avg_tot_pymt_amt as current_avg_payment,
    prev.avg_tot_pymt_amt as previous_avg_payment,
    ROUND(100.0 * (curr.total_payments - prev.total_payments) / prev.total_payments, 1) as payment_growth_pct
  FROM national_drg_trends curr
  JOIN national_drg_trends prev 
    ON curr.drg_cd = prev.drg_cd
    AND curr.mimi_src_file_date > prev.mimi_src_file_date
)

-- Final output showing top DRGs by volume with significant changes
SELECT 
  drg_cd,
  drg_desc,
  current_discharges,
  discharge_growth_pct,
  current_avg_payment,
  payment_growth_pct
FROM year_over_year
WHERE current_discharges >= 10000  -- Focus on high-volume DRGs
  AND ABS(discharge_growth_pct) >= 5  -- Show meaningful changes
ORDER BY current_discharges DESC
LIMIT 20;

-- How it works:
-- 1. First CTE gets the two most recent years from the data
-- 2. Second CTE gets national DRG data for those two years
-- 3. Third CTE calculates year-over-year changes in volume and payments
-- 4. Final query filters for high-volume DRGs with significant changes

-- Assumptions & Limitations:
-- - Requires at least 2 years of data in the table
-- - Focuses only on national-level trends
-- - 10,000 discharge threshold may need adjustment based on analysis needs
-- - Assumes 5% change is meaningful (may need adjustment)

-- Possible Extensions:
-- 1. Add service line groupings to analyze trends by clinical area
-- 2. Include additional metrics like length of stay or readmission rates
-- 3. Compare national trends to specific state patterns
-- 4. Add severity level analysis within DRG families
-- 5. Incorporate cost-to-charge ratios for margin analysis

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T17:14:46.925256
    - Additional Notes: Query focuses on high-volume DRGs (>10,000 discharges) with significant year-over-year changes (>5%). Results are limited to top 20 DRGs by current discharge volume. The analysis requires at least two years of data to be present in the source table to generate meaningful comparisons.
    
    */