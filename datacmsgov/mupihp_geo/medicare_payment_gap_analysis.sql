-- medicare_drg_charge_gap_analysis.sql

-- Business Purpose:
-- Analyze the gap between submitted charges and actual Medicare payments for DRGs
-- to identify potential pricing strategy opportunities and revenue cycle improvement areas.
-- This analysis helps hospital executives and revenue cycle managers understand:
-- 1. Which DRGs have the largest charge-to-payment gaps
-- 2. How charge capture varies across states for similar services
-- 3. Where to focus charge master and pricing strategy improvements

WITH recent_data AS (
  -- Get the most recent year's data
  SELECT DISTINCT mimi_src_file_date 
  FROM mimi_ws_1.datacmsgov.mupihp_geo
  ORDER BY mimi_src_file_date DESC
  LIMIT 1
),

drg_payment_gaps AS (
  SELECT 
    drg_cd,
    drg_desc,
    rndrng_prvdr_geo_desc AS state,
    tot_dschrgs,
    avg_submtd_cvrd_chrg,
    avg_mdcr_pymt_amt,
    -- Calculate payment gap metrics
    (avg_submtd_cvrd_chrg - avg_mdcr_pymt_amt) AS absolute_payment_gap,
    ROUND(100 * (1 - avg_mdcr_pymt_amt/avg_submtd_cvrd_chrg), 1) AS payment_gap_pct
  FROM mimi_ws_1.datacmsgov.mupihp_geo g
  CROSS JOIN recent_data rd
  WHERE g.mimi_src_file_date = rd.mimi_src_file_date
    AND rndrng_prvdr_geo_lvl = 'State'  -- Focus on state-level analysis
    AND tot_dschrgs >= 100  -- Filter for meaningful volume
)

SELECT 
  drg_cd,
  drg_desc,
  state,
  tot_dschrgs,
  ROUND(avg_submtd_cvrd_chrg, 0) AS avg_charge,
  ROUND(avg_mdcr_pymt_amt, 0) AS avg_medicare_payment,
  ROUND(absolute_payment_gap, 0) AS payment_gap,
  payment_gap_pct AS payment_gap_percentage
FROM drg_payment_gaps
WHERE payment_gap_pct >= 50  -- Focus on large gaps
ORDER BY payment_gap_pct DESC, tot_dschrgs DESC
LIMIT 100;

-- How it works:
-- 1. Identifies the most recent year of data
-- 2. Calculates payment gaps between submitted charges and Medicare payments
-- 3. Filters for meaningful volume (100+ discharges) and significant gaps (50%+)
-- 4. Returns sorted results highlighting opportunities

-- Assumptions and Limitations:
-- 1. Analysis assumes charge amounts reflect actual costs plus markup
-- 2. Limited to Medicare FFS data, may not reflect commercial pricing
-- 3. State-level aggregation masks facility-specific variations
-- 4. Volume threshold of 100 discharges is arbitrary
-- 5. Most recent year may not capture latest pricing changes

-- Possible Extensions:
-- 1. Add year-over-year trend analysis of payment gaps
-- 2. Compare state payment gaps to national averages
-- 3. Group DRGs by service line for strategic analysis
-- 4. Add case mix index adjustments
-- 5. Calculate potential revenue impact of reducing gaps
-- 6. Include geographic cost adjustments

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:00:33.843687
    - Additional Notes: The query focuses on identifying significant discrepancies between submitted charges and Medicare payments across states, with built-in thresholds for discharge volume (>=100) and payment gaps (>=50%). Results are limited to top 100 cases to highlight the most significant opportunities. Consider adjusting these thresholds based on specific analysis needs.
    
    */