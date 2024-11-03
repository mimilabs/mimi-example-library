-- Medicare Inpatient Hospital Cost and Value Analysis
--
-- Business Purpose:
-- This query analyzes Medicare inpatient hospital value and cost-effectiveness to:
-- 1. Calculate total cost burden and Medicare payment share at each facility
-- 2. Identify facilities with high out-of-pocket costs for beneficiaries 
-- 3. Compare urban vs rural hospital economics
-- 4. Support strategic planning around value-based care initiatives

WITH hospital_costs AS (
  SELECT 
    -- Hospital identifiers
    rndrng_prvdr_ccn,
    rndrng_prvdr_org_name,
    rndrng_prvdr_state_abrvtn,
    rndrng_prvdr_ruca_desc,
    
    -- Volume metrics
    tot_dschrgs AS total_discharges,
    tot_benes AS total_beneficiaries,
    
    -- Payment metrics 
    tot_submtd_cvrd_chrg AS total_submitted_charges,
    tot_pymt_amt AS total_payments,
    tot_mdcr_pymt_amt AS total_medicare_payments,
    
    -- Calculated fields
    tot_pymt_amt - tot_mdcr_pymt_amt AS estimated_patient_responsibility,
    tot_mdcr_pymt_amt / NULLIF(tot_pymt_amt, 0) AS medicare_payment_ratio,
    tot_pymt_amt / NULLIF(tot_dschrgs, 0) AS payment_per_discharge
    
  FROM mimi_ws_1.datacmsgov.mupihp_prvdr
  WHERE mimi_src_file_date = '2022-12-31' -- Most recent full year
)

SELECT
  -- Location grouping
  rndrng_prvdr_state_abrvtn AS state,
  rndrng_prvdr_ruca_desc AS location_type,
  
  -- Hospital metrics
  COUNT(DISTINCT rndrng_prvdr_ccn) AS hospital_count,
  
  -- Volume metrics
  SUM(total_discharges) AS total_discharges,
  SUM(total_beneficiaries) AS total_beneficiaries,
  
  -- Payment metrics
  ROUND(AVG(medicare_payment_ratio), 3) AS avg_medicare_payment_ratio,
  ROUND(AVG(payment_per_discharge), 0) AS avg_payment_per_discharge,
  ROUND(AVG(estimated_patient_responsibility), 0) AS avg_patient_responsibility,
  
  -- Total costs
  ROUND(SUM(total_payments)/1000000, 1) AS total_payments_millions,
  ROUND(SUM(total_medicare_payments)/1000000, 1) AS total_medicare_payments_millions

FROM hospital_costs
GROUP BY 1, 2
HAVING hospital_count >= 3 -- Suppress small cell sizes
ORDER BY total_payments_millions DESC

/*
How this works:
1. Base CTE extracts key cost and payment metrics for each hospital
2. Main query aggregates by state and urban/rural location
3. Calculated fields provide insights into Medicare vs patient payment burden
4. Results filtered to protect small provider counts

Key assumptions:
- Patient responsibility estimated as difference between total and Medicare payments
- Uses most recent complete year of data (2022)
- Excludes regions with <3 hospitals for privacy

Limitations:
- Does not account for other payer sources beyond Medicare
- Point-in-time snapshot rather than longitudinal trends
- Geographic aggregation may mask individual hospital variation

Possible extensions:
1. Add year-over-year cost trend analysis
2. Incorporate quality metrics for value assessment
3. Break out costs by major diagnosis categories
4. Add demographic factors to assess payment equity
5. Compare teaching vs non-teaching hospital economics
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:45:24.722857
    - Additional Notes: Query provides state-level comparison of Medicare vs patient payment burdens across urban/rural settings. Useful for identifying geographic variations in hospital economics and patient cost exposure. Note that the payment ratios and patient responsibility amounts are approximations since the data excludes non-Medicare payments and detailed cost-sharing breakdowns.
    
    */