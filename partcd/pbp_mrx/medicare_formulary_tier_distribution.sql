-- medicare_d_formulary_tier_analysis.sql

-- Business Purpose:
-- Analyze Medicare Part D formulary tier structures and plan design choices
-- to understand how plans organize their drug coverage and pricing.
-- This analysis helps:
-- 1. Identify prevalent formulary tier models across plans
-- 2. Assess plan choices in structuring drug benefits
-- 3. Support market analysis and competitive benchmarking

-- Main Query
WITH base_metrics AS (
  SELECT 
    mrx_form_model_type,
    mrx_formulary_tiers_num,
    COUNT(*) as plan_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) as pct_of_total
  FROM mimi_ws_1.partcd.pbp_mrx
  WHERE mrx_drug_ben_yn = 'Y'  -- Only include plans with Part D benefits
  GROUP BY 
    mrx_form_model_type,
    mrx_formulary_tiers_num
),
tier_breakout AS (
  SELECT 
    CASE 
      WHEN mrx_formulary_tiers_num = 2 THEN '2 Tiers'
      WHEN mrx_formulary_tiers_num = 3 THEN '3 Tiers'
      WHEN mrx_formulary_tiers_num = 4 THEN '4 Tiers'
      WHEN mrx_formulary_tiers_num = 5 THEN '5 Tiers'
      WHEN mrx_formulary_tiers_num = 6 THEN '6 Tiers'
      ELSE 'Other'
    END as tier_category,
    COUNT(*) as plans,
    ROUND(AVG(CAST(mrx_alt_ded_amount as FLOAT)), 2) as avg_deductible,
    COUNT(CASE WHEN mrx_alt_gap_covg_yn = 'Y' THEN 1 END) as plans_with_gap_coverage
  FROM mimi_ws_1.partcd.pbp_mrx
  WHERE mrx_drug_ben_yn = 'Y'
  GROUP BY 
    CASE 
      WHEN mrx_formulary_tiers_num = 2 THEN '2 Tiers'
      WHEN mrx_formulary_tiers_num = 3 THEN '3 Tiers'
      WHEN mrx_formulary_tiers_num = 4 THEN '4 Tiers'
      WHEN mrx_formulary_tiers_num = 5 THEN '5 Tiers'
      WHEN mrx_formulary_tiers_num = 6 THEN '6 Tiers'
      ELSE 'Other'
    END
)

SELECT
  bm.mrx_form_model_type,
  bm.mrx_formulary_tiers_num,
  bm.plan_count,
  bm.pct_of_total as pct_of_plans,
  tb.avg_deductible,
  tb.plans_with_gap_coverage,
  ROUND(tb.plans_with_gap_coverage * 100.0 / tb.plans, 2) as pct_with_gap_coverage
FROM base_metrics bm
JOIN tier_breakout tb 
  ON CASE 
       WHEN bm.mrx_formulary_tiers_num = 2 THEN '2 Tiers'
       WHEN bm.mrx_formulary_tiers_num = 3 THEN '3 Tiers'
       WHEN bm.mrx_formulary_tiers_num = 4 THEN '4 Tiers'
       WHEN bm.mrx_formulary_tiers_num = 5 THEN '5 Tiers'
       WHEN bm.mrx_formulary_tiers_num = 6 THEN '6 Tiers'
       ELSE 'Other'
     END = tb.tier_category
ORDER BY 
  bm.mrx_formulary_tiers_num,
  bm.plan_count DESC;

-- How this works:
-- 1. Creates base metrics for formulary models and tier counts
-- 2. Calculates tier-specific statistics including deductibles and gap coverage
-- 3. Joins the information together for a comprehensive view of formulary structures
-- 4. Provides percentages and averages for easy comparison

-- Assumptions and Limitations:
-- - Only includes active plans with Part D benefits
-- - Deductible amounts are averaged across all plans in a tier category
-- - Gap coverage is counted as binary (yes/no) without considering extent of coverage
-- - Does not account for seasonal or mid-year changes in plan design

-- Possible Extensions:
-- 1. Add temporal analysis to track changes in formulary structures over time
-- 2. Include cost-sharing analysis at the tier level
-- 3. Incorporate geographic variation in formulary designs
-- 4. Add analysis of specialty tier placement and utilization management
-- 5. Compare formulary structures across different plan types (MA-PD vs PDP)

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:15:39.590383
    - Additional Notes: The query aggregates Medicare Part D formulary structures across plans, providing insights into tier model distribution and associated features like deductibles and gap coverage. While comprehensive for basic plan design analysis, it doesn't reflect mid-year changes or detailed cost-sharing structures at the drug level. Best used for high-level market analysis and plan design benchmarking.
    
    */