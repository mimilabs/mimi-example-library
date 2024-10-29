-- Regional Medicare Hospital Performance Analysis
--
-- Business Purpose: 
-- This query analyzes Medicare inpatient hospital performance by geographic region to:
-- 1. Compare hospital density, utilization patterns and costs across urban vs rural areas
-- 2. Identify areas that may need additional hospital capacity or support
-- 3. Support strategic planning for healthcare resource allocation
-- 4. Help policymakers understand regional variations in Medicare hospital services

WITH hospital_metrics AS (
  SELECT 
    -- Geographic grouping
    rndrng_prvdr_state_abrvtn as state,
    rndrng_prvdr_ruca_desc as rural_urban_class,
    COUNT(DISTINCT rndrng_prvdr_ccn) as hospital_count,
    
    -- Utilization metrics
    SUM(tot_dschrgs) as total_discharges,
    SUM(tot_cvrd_days) as total_covered_days,
    AVG(tot_dschrgs * 1.0) as avg_discharges_per_hospital,
    
    -- Financial metrics  
    SUM(tot_mdcr_pymt_amt) as total_medicare_payments,
    AVG(tot_mdcr_pymt_amt/NULLIF(tot_dschrgs,0)) as avg_payment_per_discharge,
    
    -- Case mix indicators
    AVG(bene_avg_risk_scre) as avg_risk_score,
    AVG(bene_avg_age) as avg_patient_age

  FROM mimi_ws_1.datacmsgov.mupihp_prvdr
  WHERE mimi_src_file_date = '2022-12-31' -- Most recent full year
  GROUP BY 1, 2
)

SELECT
  state,
  rural_urban_class,
  hospital_count,
  total_discharges,
  ROUND(avg_discharges_per_hospital,0) as avg_discharges_per_hospital,
  ROUND(total_medicare_payments/1000000,2) as total_medicare_payments_millions,
  ROUND(avg_payment_per_discharge,0) as avg_payment_per_discharge,
  ROUND(avg_risk_score,2) as avg_risk_score,
  ROUND(avg_patient_age,1) as avg_patient_age
FROM hospital_metrics
ORDER BY state, rural_urban_class;

-- How this works:
-- 1. Creates hospital_metrics CTE to aggregate key performance metrics by state and rural/urban classification
-- 2. Calculates volume, financial, and patient metrics for each geographic segment
-- 3. Formats final output with readable metrics and appropriate rounding
--
-- Assumptions & Limitations:
-- - Uses most recent full year of data (2022)
-- - Rural/urban classifications are based on RUCA codes which may not capture all nuances
-- - Medicare payments exclude beneficiary cost sharing and other payer amounts
-- - Some rural areas may have small numbers that affect averages
--
-- Possible Extensions:
-- 1. Add year-over-year trend analysis to identify changing patterns
-- 2. Include additional metrics like length of stay or readmission rates
-- 3. Add filters for specific hospital types or size categories
-- 4. Create geographic visualizations of the results
-- 5. Analyze seasonal variations in hospital utilization by region

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T19:20:14.980292
    - Additional Notes: Query segments Medicare hospital data by geographic region and rural/urban status to analyze capacity and performance variations. The metrics focus on hospital density, utilization patterns, and financial performance across different geographic areas. Note that some rural regions may have data limitations due to small sample sizes.
    
    */