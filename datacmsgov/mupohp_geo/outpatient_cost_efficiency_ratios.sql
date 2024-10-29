-- Title: Regional Outpatient Cost Efficiency Analysis
--
-- Business Purpose: 
-- This query analyzes cost efficiency metrics for Medicare outpatient services across regions
-- by comparing submitted charges to allowed amounts. This helps identify areas with high 
-- charge-to-payment ratios and potential cost optimization opportunities.
--
-- The analysis supports:
-- - Strategic market assessment for healthcare providers
-- - Value-based care program planning
-- - Regional cost variation analysis
-- - Network efficiency optimization

WITH cost_ratios AS (
  SELECT 
    rndrng_prvdr_geo_desc as state,
    apc_desc,
    SUM(capc_srvcs) as total_services,
    SUM(bene_cnt) as total_beneficiaries,
    AVG(avg_tot_sbmtd_chrgs) as avg_submitted_charge,
    AVG(avg_mdcr_alowd_amt) as avg_allowed_amount,
    (AVG(avg_tot_sbmtd_chrgs) / NULLIF(AVG(avg_mdcr_alowd_amt), 0)) as charge_to_allowed_ratio
  FROM mimi_ws_1.datacmsgov.mupohp_geo
  WHERE mimi_src_file_date = '2022-12-31'
    AND rndrng_prvdr_geo_lvl = 'State'
    AND srvc_lvl = 'APC'
  GROUP BY 1, 2
)

SELECT 
  state,
  apc_desc,
  total_services,
  total_beneficiaries,
  ROUND(avg_submitted_charge, 2) as avg_submitted_charge,
  ROUND(avg_allowed_amount, 2) as avg_allowed_amount,
  ROUND(charge_to_allowed_ratio, 2) as charge_to_allowed_ratio,
  -- Flag high variation services
  CASE 
    WHEN charge_to_allowed_ratio > 3.0 THEN 'High Variation'
    WHEN charge_to_allowed_ratio < 2.0 THEN 'Low Variation'
    ELSE 'Moderate Variation'
  END as cost_variation_category
FROM cost_ratios
WHERE total_services > 100  -- Focus on services with meaningful volume
ORDER BY charge_to_allowed_ratio DESC
LIMIT 50;

-- How it works:
-- 1. Creates a CTE to calculate cost efficiency metrics by state and service
-- 2. Computes the ratio between submitted charges and allowed amounts
-- 3. Applies volume threshold to focus on statistically significant services
-- 4. Categorizes services based on charge-to-allowed ratios
-- 5. Returns top 50 results ordered by highest variation

-- Assumptions and Limitations:
-- - Assumes 2022 data is most recent and complete
-- - Requires sufficient service volume for meaningful analysis
-- - Does not account for regional cost of living differences
-- - Charge-to-allowed ratio thresholds are illustrative and may need adjustment

-- Possible Extensions:
-- 1. Add year-over-year trend analysis
-- 2. Include geographic clustering analysis
-- 3. Incorporate demographic and socioeconomic factors
-- 4. Add statistical significance testing
-- 5. Create peer group comparisons based on state characteristics/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-29T18:09:16.840823
    - Additional Notes: This query focuses on the relationship between submitted charges and allowed amounts, which is a key metric for understanding regional cost variations in outpatient services. The charge-to-allowed ratio threshold of 3.0 for 'High Variation' classification may need to be adjusted based on specific analysis needs and regional characteristics.
    
    */