-- Title: Healthcare.gov Formulary Analysis - Drug Coverage and Access Restrictions
-- 
-- Business Purpose:
-- This query analyzes drug coverage and access restrictions across health plans on healthcare.gov
-- to identify potential barriers to care and compare plan generosity.
-- Key metrics include:
-- - Total drugs covered per plan
-- - % of drugs requiring prior authorization
-- - % of drugs requiring step therapy
-- - Distribution across drug tiers
--
-- Author: Healthcare Analytics Team
-- Created: 2024

WITH plan_metrics AS (
  SELECT 
    plan_id,
    COUNT(DISTINCT rxnorm_id) as total_drugs,
    AVG(CASE WHEN prior_authorization = 'Yes' THEN 1 ELSE 0 END) * 100 as pct_prior_auth,
    AVG(CASE WHEN step_therapy = 'Yes' THEN 1 ELSE 0 END) * 100 as pct_step_therapy,
    AVG(CASE WHEN quantity_limit = 'Yes' THEN 1 ELSE 0 END) * 100 as pct_qty_limit
  FROM mimi_ws_1.datahealthcaregov.formulary_details
  WHERE ARRAY_CONTAINS(years, 2023) -- Modified to handle array type
  GROUP BY plan_id
)

SELECT
  -- Plan level metrics
  p.plan_id,
  p.total_drugs,
  ROUND(p.pct_prior_auth, 1) as pct_prior_auth,
  ROUND(p.pct_step_therapy, 1) as pct_step_therapy,
  ROUND(p.pct_qty_limit, 1) as pct_qty_limit,
  
  -- Add tier distribution
  COUNT(CASE WHEN f.drug_tier = '1' THEN 1 END) as tier_1_drugs,
  COUNT(CASE WHEN f.drug_tier = '2' THEN 1 END) as tier_2_drugs,
  COUNT(CASE WHEN f.drug_tier = '3' THEN 1 END) as tier_3_drugs,
  COUNT(CASE WHEN f.drug_tier = '4' THEN 1 END) as tier_4_drugs

FROM plan_metrics p
JOIN mimi_ws_1.datahealthcaregov.formulary_details f
  ON p.plan_id = f.plan_id
WHERE ARRAY_CONTAINS(f.years, 2023) -- Modified to handle array type
GROUP BY 
  p.plan_id,
  p.total_drugs,
  p.pct_prior_auth,
  p.pct_step_therapy,
  p.pct_qty_limit
ORDER BY p.total_drugs DESC
LIMIT 100;

-- How it works:
-- 1. Creates plan_metrics CTE to calculate key statistics per plan
-- 2. Joins back to main table to add tier distribution
-- 3. Returns top 100 plans by drug coverage with key metrics
--
-- Assumptions:
-- - Uses current year (2023) data only
-- - Assumes binary Yes/No values for restriction flags
-- - Limited to standard 4-tier formulary structure
-- - Years column is an array type
--
-- Limitations:
-- - Does not account for plan enrollment or market share
-- - Drug tiers may vary across plans
-- - Point-in-time snapshot only
--
-- Possible Extensions:
-- 1. Add year-over-year comparison
-- 2. Include specific drug class analysis
-- 3. Add geographic/state level aggregation
-- 4. Compare to industry benchmarks
-- 5. Add cost sharing analysis if available
-- 6. Include specialty drug specific metrics

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-01T18:48:21.642863
    - Additional Notes: Query requires year data stored as array type in the years column. Currently configured for 2023 data only. Drug tier values are assumed to be string type ('1', '2', etc.). All percentage metrics are rounded to 1 decimal place.
    
    */