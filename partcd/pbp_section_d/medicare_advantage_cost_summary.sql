-- Medicare Advantage Plan Cost Sharing Analysis
-- Purpose: Analyze key financial aspects of Medicare Advantage plans to understand 
-- premium costs, deductibles, and out-of-pocket maximums that impact beneficiaries.

WITH plan_counts AS (
  -- Get total count of plans and plans with deductibles
  SELECT 
    COUNT(DISTINCT bid_id) as total_plans,
    COUNT(DISTINCT CASE WHEN pbp_d_ann_deduct_yn = 'Y' THEN bid_id END) as plans_with_deductible
  FROM mimi_ws_1.partcd.pbp_section_d
),
cost_metrics AS (
  -- Calculate average costs across plans
  SELECT 
    AVG(CAST(pbp_d_mplusc_premium AS FLOAT)) as avg_premium,
    AVG(CASE WHEN pbp_d_ann_deduct_yn = 'Y' 
        THEN CAST(pbp_d_ann_deduct_amt AS FLOAT) END) as avg_deductible,
    AVG(CAST(pbp_d_out_pocket_amt AS FLOAT)) as avg_moop
  FROM mimi_ws_1.partcd.pbp_section_d
  WHERE pbp_d_mplusc_premium IS NOT NULL
)
SELECT
  p.total_plans,
  p.plans_with_deductible,
  ROUND(p.plans_with_deductible * 100.0 / p.total_plans, 1) as pct_with_deductible,
  ROUND(c.avg_premium, 2) as avg_monthly_premium,
  ROUND(c.avg_deductible, 2) as avg_annual_deductible,
  ROUND(c.avg_moop, 2) as avg_max_out_of_pocket
FROM plan_counts p
CROSS JOIN cost_metrics c;

/* How this query works:
1. First CTE counts total plans and plans offering deductibles
2. Second CTE calculates average premium, deductible and out-of-pocket costs
3. Main query joins these metrics and formats results with percentages

Assumptions & Limitations:
- Assumes premium/deductible/MOOP amounts are stored as valid numbers
- Null values are excluded from averages
- Does not account for plan enrollment numbers (unweighted averages)
- Does not segment by plan type or geography

Possible Extensions:
1. Add geographic analysis by state/county
2. Segment by plan type (HMO vs PPO)
3. Add year-over-year trend analysis
4. Include enrollment-weighted averages
5. Add premium reduction analysis
6. Compare in-network vs out-of-network costs
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-06T00:23:40.260197
    - Additional Notes: Query provides high-level financial metrics for Medicare Advantage plans. Note that results are unweighted by enrollment and may not reflect actual beneficiary experience. Cost calculations exclude null values and assume valid numeric data in source fields. For trend analysis or geographic comparisons, script needs to be modified to include relevant dimensions.
    
    */