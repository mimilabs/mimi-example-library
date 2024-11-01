-- Medicare Part D Mail Order Incentive Analysis
-- 
-- Business Purpose:
-- Analyzes how Medicare Part D plans structure their mail order prescription drug benefits
-- to encourage beneficiaries to use mail order pharmacies for chronic medications.
-- This helps healthcare organizations understand cost-saving opportunities and 
-- patient convenience strategies across different plans.

WITH mail_order_differentials AS (
  SELECT 
    pbp_a_hnumber,
    pbp_a_plan_identifier,
    mrx_tier_id,
    mrx_tier_label_list,
    -- Calculate 90-day retail vs mail order cost difference
    mrx_tier_rstd_copay_3m AS retail_90day_copay,
    mrx_tier_mospfd_copay_3m AS mail_90day_copay,
    -- Calculate the savings from mail order
    (COALESCE(mrx_tier_rstd_copay_3m,0) - COALESCE(mrx_tier_mospfd_copay_3m,0)) AS mail_order_savings,
    -- Calculate savings percentage 
    CASE 
      WHEN mrx_tier_rstd_copay_3m > 0 
      THEN ROUND(((mrx_tier_rstd_copay_3m - mrx_tier_mospfd_copay_3m) / mrx_tier_rstd_copay_3m) * 100, 1)
      ELSE NULL 
    END AS savings_percentage,
    -- Flag plans with strong mail order incentives
    CASE
      WHEN (mrx_tier_rstd_copay_3m - mrx_tier_mospfd_copay_3m) >= 20 THEN 'Strong'
      WHEN (mrx_tier_rstd_copay_3m - mrx_tier_mospfd_copay_3m) >= 10 THEN 'Moderate'
      ELSE 'Weak'
    END AS incentive_level
  FROM mimi_ws_1.partcd.pbp_mrx_tier
  WHERE 
    mrx_tier_rstd_copay_3m IS NOT NULL
    AND mrx_tier_mospfd_copay_3m IS NOT NULL
    -- Focus on maintenance medication tiers
    AND LOWER(mrx_tier_label_list) LIKE '%preferred%'
)

SELECT
  incentive_level,
  COUNT(DISTINCT pbp_a_plan_identifier) AS plan_count,
  ROUND(AVG(mail_order_savings),2) AS avg_dollar_savings,
  ROUND(AVG(savings_percentage),1) AS avg_savings_percentage,
  -- Get sample of tier labels
  MAX(mrx_tier_label_list) AS sample_tier_label
FROM mail_order_differentials
GROUP BY incentive_level
ORDER BY plan_count DESC;

-- How this query works:
-- 1. Creates CTE to calculate mail order vs retail pricing differentials
-- 2. Focuses on 90-day supplies where mail order benefits are most relevant
-- 3. Categorizes plans based on strength of mail order incentives
-- 4. Aggregates results to show patterns in plan design strategies

-- Assumptions & Limitations:
-- - Only analyzes copay differentials, not coinsurance
-- - Focuses on preferred tiers where maintenance medications are typically placed
-- - Does not account for other mail order incentives like free shipping
-- - Limited to plans that report both retail and mail order copays

-- Possible Extensions:
-- 1. Add geographic analysis to see regional variations in mail order incentives
-- 2. Include year-over-year trend analysis of mail order incentive structures
-- 3. Correlate mail order incentives with plan enrollment numbers
-- 4. Analyze specific therapeutic categories and their mail order pricing
-- 5. Add analysis of auto-refill program availability

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T17:40:32.519080
    - Additional Notes: This analysis focuses on mail order pharmacy cost incentives in Medicare Part D plans, comparing 90-day supply costs between retail and mail order channels. The script only considers copayments (not coinsurance) and requires both retail and mail order pricing to be present. Results are categorized into Strong/Moderate/Weak incentive levels based on dollar amount savings.
    
    */