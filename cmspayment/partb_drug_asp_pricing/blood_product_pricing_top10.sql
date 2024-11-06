-- blood_product_reimbursement_analysis.sql

-- Business Purpose:
-- This query analyzes Medicare Part B blood product reimbursement rates and payment limits
-- to help healthcare organizations optimize blood product inventory management and 
-- understand cost implications for transfusion services.
-- The insights support blood bank operations, cost forecasting, and reimbursement planning.

WITH blood_products AS (
  -- Filter and rank blood products by payment limits
  SELECT 
    hcpcs_code,
    short_description,
    blood_limit,
    blood_awp_pct,
    payment_limit,
    coinsurance_percentage,
    mimi_src_file_date,
    -- Rank products by payment limit within each reporting period
    ROW_NUMBER() OVER (PARTITION BY mimi_src_file_date ORDER BY blood_limit DESC) as cost_rank
  FROM mimi_ws_1.cmspayment.partb_drug_asp_pricing
  WHERE blood_limit IS NOT NULL 
    AND mimi_src_file_date >= '2022-01-01'
)

SELECT 
  hcpcs_code,
  short_description,
  blood_limit,
  blood_awp_pct,
  payment_limit,
  coinsurance_percentage,
  mimi_src_file_date,
  cost_rank
FROM blood_products 
WHERE cost_rank <= 10  -- Focus on top 10 highest reimbursed products
ORDER BY mimi_src_file_date DESC, cost_rank;

-- How this works:
-- 1. Creates CTE to identify blood products with valid blood_limit values
-- 2. Ranks products by blood_limit within each reporting period
-- 3. Filters to most recent quarters and top 10 products by reimbursement
-- 4. Returns key pricing and reimbursement metrics for analysis

-- Assumptions & Limitations:
-- - Assumes blood_limit field accurately reflects blood product reimbursement
-- - Limited to products with explicit blood product pricing
-- - Does not account for facility-specific payment adjustments
-- - Historical analysis limited to available quarters in dataset

-- Possible Extensions:
-- 1. Add quarter-over-quarter pricing trend analysis
-- 2. Include volume/utilization data by matching to claims
-- 3. Compare blood product vs general drug reimbursement rates
-- 4. Add filters for specific blood product categories
-- 5. Calculate total expected reimbursement including coinsurance

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:52:10.702091
    - Additional Notes: Query specifically focuses on the top 10 blood products by reimbursement rate per quarter, useful for blood bank financial planning and inventory management. Limited to records from 2022 onward and requires blood_limit values to be populated.
    
    */