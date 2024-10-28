
/*******************************************************
Medicare Part D Plan Benefit Analysis
********************************************************

This query analyzes key aspects of Medicare Part D prescription drug plans 
to understand benefit design and coverage variations across plans.

Business Purpose:
- Understand plan benefit structures and coverage patterns
- Compare deductible amounts and tier structures 
- Identify plans with enhanced benefits and gap coverage
- Support analysis of beneficiary access and plan choices

Created 2024-02
********************************************************/

WITH plan_benefits AS (
  SELECT 
    bid_id,
    mrx_drug_ben_yn as offers_drug_benefit,
    mrx_formulary_tiers_num as num_tiers,
    mrx_alt_ded_amount as deductible_amt,
    mrx_alt_gap_covg_yn as has_gap_coverage,
    mrx_alt_red_cost_sharing as has_reduced_cost_share,
    mrx_first_fill as has_free_first_fill,
    CASE WHEN mrx_alt_ded_amount = 0 THEN 1 ELSE 0 END as zero_deductible
  FROM mimi_ws_1.partcd.pbp_mrx
  WHERE mrx_drug_ben_yn = 'Y' -- Only include plans offering drug benefits
)

SELECT
  -- Plan structure metrics
  COUNT(DISTINCT bid_id) as total_plans,
  AVG(num_tiers) as avg_tiers,
  
  -- Cost sharing features
  AVG(deductible_amt) as avg_deductible,
  SUM(zero_deductible)::FLOAT/COUNT(*) as pct_zero_deductible,
  
  -- Enhanced benefits
  SUM(CASE WHEN has_gap_coverage = 'Y' THEN 1 ELSE 0 END)::FLOAT/COUNT(*) as pct_with_gap_coverage,
  SUM(CASE WHEN has_reduced_cost_share = 'Y' THEN 1 ELSE 0 END)::FLOAT/COUNT(*) as pct_reduced_cost_share,
  SUM(CASE WHEN has_free_first_fill = 'Y' THEN 1 ELSE 0 END)::FLOAT/COUNT(*) as pct_free_first_fill

FROM plan_benefits;

/*
HOW IT WORKS:
1. CTE extracts key benefit design features for each plan
2. Main query calculates summary statistics across all plans
3. Results show prevalence of various benefit features

ASSUMPTIONS & LIMITATIONS:
- Assumes current year data
- Only includes active plans with drug benefits
- Does not account for regional variations
- Does not consider premium costs

POSSIBLE EXTENSIONS:
1. Add geographic analysis by state/region
2. Compare benefit features across plan types
3. Analyze trends over multiple years
4. Include premium data for cost/benefit analysis
5. Add specialty drug coverage analysis
********************************************************/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:45:23.702659
    - Additional Notes: Query aggregates key Medicare Part D plan features including deductibles, gap coverage, and cost-sharing structures. Results show overall market prevalence of various benefit designs. Note that the analysis excludes premium costs and regional variations which may impact overall plan value.
    
    */