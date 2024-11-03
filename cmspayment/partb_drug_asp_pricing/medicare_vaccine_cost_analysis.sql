-- vaccine_pricing_insights.sql
-- Business Purpose:
-- This query analyzes vaccine pricing and reimbursement patterns in Medicare Part B,
-- helping healthcare organizations optimize vaccine programs and understand cost variations.
-- The insights support vaccination program planning, budget forecasting, and cost management.

WITH vaccine_stats AS (
  -- Get latest pricing data for vaccines
  SELECT 
    hcpcs_code,
    short_description,
    hcpcs_code_dosage,
    vaccine_limit,
    vaccine_awp_pct,
    payment_limit,
    mimi_src_file_date
  FROM mimi_ws_1.cmspayment.partb_drug_asp_pricing
  WHERE vaccine_awp_pct IS NOT NULL
    AND mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                             FROM mimi_ws_1.cmspayment.partb_drug_asp_pricing)
),

pricing_summary AS (
  -- Calculate key pricing metrics
  SELECT
    COUNT(DISTINCT hcpcs_code) as total_vaccines,
    ROUND(AVG(vaccine_limit),2) as avg_vaccine_limit,
    ROUND(MAX(vaccine_limit),2) as max_vaccine_limit,
    ROUND(MIN(vaccine_limit),2) as min_vaccine_limit,
    ROUND(AVG(vaccine_awp_pct),1) as avg_awp_pct
  FROM vaccine_stats
)

-- Combine detailed vaccine info with summary metrics
SELECT 
  v.hcpcs_code,
  v.short_description,
  v.hcpcs_code_dosage,
  v.vaccine_limit,
  v.vaccine_awp_pct,
  v.payment_limit,
  ps.total_vaccines,
  ps.avg_vaccine_limit,
  ROUND(((v.vaccine_limit - ps.avg_vaccine_limit)/ps.avg_vaccine_limit) * 100, 1) as pct_diff_from_avg
FROM vaccine_stats v
CROSS JOIN pricing_summary ps
WHERE v.vaccine_limit > ps.avg_vaccine_limit
ORDER BY v.vaccine_limit DESC;

-- How this query works:
-- 1. Creates a CTE for latest vaccine pricing data
-- 2. Calculates summary statistics across all vaccines
-- 3. Identifies vaccines priced above average with comparative metrics
-- 4. Orders results by vaccine limit to highlight highest-cost items

-- Assumptions and limitations:
-- 1. Focuses only on vaccines (excludes other drug categories)
-- 2. Uses most recent pricing data only
-- 3. Assumes vaccine_awp_pct is the key indicator for vaccine status
-- 4. Does not account for seasonal variations or regional differences

-- Possible extensions:
-- 1. Add trending analysis across multiple quarters
-- 2. Include coinsurance impact analysis
-- 3. Compare vaccine costs to similar therapeutic categories
-- 4. Add volume/utilization data if available
-- 5. Incorporate therapeutic classification groupings

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:57:15.910645
    - Additional Notes: Query focuses specifically on Medicare Part B vaccine pricing patterns and cost variations above average. Relies on vaccine_awp_pct field being populated to identify vaccine products. Most useful for quarterly budget planning and vaccine program cost management.
    
    */