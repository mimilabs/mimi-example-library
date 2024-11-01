-- Medicare Part D Pharmacy Network Analysis
-- 
-- Business Purpose:
-- Analyzes the pharmacy network strategy and cost-sharing differentials across retail, mail-order, and 
-- preferred/non-preferred pharmacies for Medicare Part D plans. This helps understand how plans design
-- their networks to influence beneficiary pharmacy choices and manage costs.
--
-- The analysis identifies plans with significant cost differentials between pharmacy types,
-- which is valuable for:
-- - Health plans designing pharmacy networks
-- - Pharmacies negotiating network contracts
-- - Consultants advising on network optimization
-- - Regulators monitoring network adequacy

WITH pharmacy_differentials AS (
  -- Calculate cost-sharing differentials between pharmacy types for 1-month supply
  SELECT 
    bid_id,
    mrx_tier_id,
    mrx_tier_label_list,
    
    -- Retail pharmacy differential
    COALESCE(mrx_tier_rspfd_copay_1m,0) - COALESCE(mrx_tier_rstd_copay_1m,0) AS retail_copay_diff,
    COALESCE(mrx_tier_rspfd_coins_1m,0) - COALESCE(mrx_tier_rstd_coins_1m,0) AS retail_coins_diff,
    
    -- Mail order differential  
    COALESCE(mrx_tier_mospfd_copay_1m,0) - COALESCE(mrx_tier_mostd_copay_1m,0) AS mail_copay_diff,
    COALESCE(mrx_tier_mospfd_coins_1m,0) - COALESCE(mrx_tier_mostd_coins_1m,0) AS mail_coins_diff,
    
    -- Mail vs retail differential
    COALESCE(mrx_tier_mospfd_copay_1m,0) - COALESCE(mrx_tier_rspfd_copay_1m,0) AS mail_vs_retail_copay_diff
  FROM mimi_ws_1.partcd.pbp_mrx_tier
  WHERE mrx_tier_label_list IS NOT NULL
)

SELECT
  bid_id,
  mrx_tier_label_list,
  COUNT(*) AS tier_count,
  
  -- Average differentials
  ROUND(AVG(retail_copay_diff),2) AS avg_retail_copay_diff,
  ROUND(AVG(retail_coins_diff),2) AS avg_retail_coins_diff,
  ROUND(AVG(mail_copay_diff),2) AS avg_mail_copay_diff,
  ROUND(AVG(mail_coins_diff),2) AS avg_mail_coins_diff,
  ROUND(AVG(mail_vs_retail_copay_diff),2) AS avg_mail_vs_retail_diff,
  
  -- Maximum differentials
  MAX(retail_copay_diff) AS max_retail_copay_diff,
  MAX(mail_copay_diff) AS max_mail_copay_diff

FROM pharmacy_differentials
GROUP BY bid_id, mrx_tier_label_list
HAVING COUNT(*) > 0
ORDER BY avg_retail_copay_diff DESC
LIMIT 100;

-- How this query works:
-- 1. Creates a CTE to calculate cost-sharing differentials between pharmacy types
-- 2. Focuses on 1-month supply to enable direct comparisons
-- 3. Calculates differentials for both copays and coinsurance
-- 4. Aggregates results by plan and tier to identify patterns
-- 5. Orders results by retail copay differential to highlight plans with aggressive network steering

-- Assumptions and Limitations:
-- - Focus on 1-month supply only
-- - Null values treated as zero in differential calculations
-- - Does not account for drug-specific variations within tiers
-- - Limited to 100 most significant differentials

-- Possible Extensions:
-- 1. Add geographic analysis to identify regional network patterns
-- 2. Include trend analysis across multiple years
-- 3. Incorporate mail order utilization data to assess effectiveness
-- 4. Add filters for specific drug tiers or plan types
-- 5. Calculate weighted averages based on enrollment

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:28:10.577527
    - Additional Notes: Query focuses on preferred vs non-preferred pharmacy cost differentials and may need adjustment for plans with unique network structures or specialized tier designs. Performance may be impacted with very large datasets due to multiple COALESCE operations.
    
    */