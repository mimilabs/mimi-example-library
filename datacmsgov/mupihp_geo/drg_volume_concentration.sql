-- inpatient_hospital_drg_concentration.sql 

-- Business Purpose: 
-- Analyze the concentration of inpatient services across DRGs to identify 
-- which conditions/procedures make up the bulk of Medicare inpatient volume.
-- This helps hospitals and health systems understand service line focus areas
-- and potential opportunities for specialization or expansion.

WITH recent_data AS (
  -- Get most recent year's data
  SELECT DISTINCT mimi_src_file_date 
  FROM mimi_ws_1.datacmsgov.mupihp_geo
  ORDER BY mimi_src_file_date DESC
  LIMIT 1
),

national_totals AS (
  -- Calculate national volume and payments by DRG
  SELECT 
    drg_cd,
    drg_desc,
    SUM(tot_dschrgs) as total_discharges,
    AVG(avg_tot_pymt_amt) as avg_payment,
    SUM(tot_dschrgs * avg_tot_pymt_amt) as total_payments
  FROM mimi_ws_1.datacmsgov.mupihp_geo m
  WHERE mimi_src_file_date = (SELECT mimi_src_file_date FROM recent_data)
    AND rndrng_prvdr_geo_lvl = 'National'
  GROUP BY drg_cd, drg_desc
)

SELECT
  drg_cd,
  drg_desc,
  total_discharges,
  avg_payment,
  total_payments,
  -- Calculate percentage metrics
  ROUND(100.0 * total_discharges / SUM(total_discharges) OVER(), 2) as pct_total_discharges,
  ROUND(100.0 * total_payments / SUM(total_payments) OVER(), 2) as pct_total_payments,
  -- Calculate running totals
  SUM(total_discharges) OVER(ORDER BY total_discharges DESC) as running_sum_discharges,
  ROUND(100.0 * SUM(total_discharges) OVER(ORDER BY total_discharges DESC) / 
    SUM(total_discharges) OVER(), 2) as running_pct_discharges
FROM national_totals
ORDER BY total_discharges DESC
LIMIT 20;

-- How this works:
-- 1. Identifies most recent year of data
-- 2. Calculates national totals by DRG from national-level records
-- 3. Computes volume and payment percentages and running totals
-- 4. Returns top 20 DRGs by discharge volume with concentration metrics

-- Assumptions & Limitations:
-- - Uses national level data only
-- - Based on Medicare FFS data only, not Medicare Advantage
-- - Does not account for clinical relationships between DRGs
-- - Point-in-time analysis for most recent year

-- Possible Extensions:
-- 1. Add year-over-year growth rates for volume and payments
-- 2. Group DRGs into clinical service lines
-- 3. Compare concentration patterns across states
-- 4. Add case mix index and complexity metrics
-- 5. Include length of stay and cost per day calculations
-- 6. Analyze seasonal patterns in high-volume DRGs

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:38:27.345666
    - Additional Notes: Query focuses on DRG concentration metrics at the national level, highlighting which diagnosis groups account for the largest portions of Medicare inpatient volume and spend. The running totals are particularly useful for understanding how many DRGs need to be managed to cover specific percentages of total patient volume. Consider memory usage when analyzing full dataset as calculations involve window functions across all DRGs.
    
    */