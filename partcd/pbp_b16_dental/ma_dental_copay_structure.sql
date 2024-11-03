-- Medicare Advantage Dental Service Copayment Analysis
-- Business Purpose: Analyze copayment structures for dental services across MA plans
-- to understand out-of-pocket costs for beneficiaries, identify plans with 
-- cost-effective dental benefits, and support member education and plan selection.

WITH dental_copays AS (
  SELECT 
    pbp_a_plan_type,
    COUNT(DISTINCT bid_id) as total_plans,
    
    -- Analyze preventive service copays
    SUM(CASE WHEN pbp_b16b_copay_pc_yn = 'Y' THEN 1 ELSE 0 END) as plans_with_preventive_copay,
    AVG(NULLIF(pbp_b16b_copay_pc_amt, 0)) as avg_preventive_copay,
    
    -- Analyze diagnostic service copays  
    SUM(CASE WHEN pbp_b16b_copay_dx_yn = 'Y' THEN 1 ELSE 0 END) as plans_with_diagnostic_copay,
    AVG(NULLIF(pbp_b16b_copay_dx_amt, 0)) as avg_diagnostic_copay,
    
    -- Analyze restorative service copays
    SUM(CASE WHEN pbp_b16c_copay_rs_yn = 'Y' THEN 1 ELSE 0 END) as plans_with_restorative_copay,
    AVG(NULLIF(pbp_b16c_copay_rs_amt, 0)) as avg_restorative_copay

  FROM mimi_ws_1.partcd.pbp_b16_dental
  GROUP BY pbp_a_plan_type
)

SELECT
  pbp_a_plan_type as plan_type,
  total_plans,
  
  -- Calculate percentages of plans with copays
  ROUND(plans_with_preventive_copay * 100.0 / total_plans, 1) as pct_plans_preventive_copay,
  ROUND(avg_preventive_copay, 2) as avg_preventive_copay_amt,
  
  ROUND(plans_with_diagnostic_copay * 100.0 / total_plans, 1) as pct_plans_diagnostic_copay,  
  ROUND(avg_diagnostic_copay, 2) as avg_diagnostic_copay_amt,
  
  ROUND(plans_with_restorative_copay * 100.0 / total_plans, 1) as pct_plans_restorative_copay,
  ROUND(avg_restorative_copay, 2) as avg_restorative_copay_amt

FROM dental_copays
WHERE total_plans >= 10  -- Filter to plan types with meaningful sample sizes
ORDER BY total_plans DESC;

/* How this query works:
1. Creates CTE to aggregate copay metrics by plan type
2. Counts total plans and plans with copays for each service category
3. Calculates average copay amounts where copays exist
4. Final SELECT formats percentages and amounts for analysis
5. Filters to plan types with 10+ plans for statistical relevance

Assumptions & Limitations:
- Assumes $0 copays indicate no copay rather than free service
- Averages may be skewed by outliers
- Does not account for varied copay structures or tiering
- Limited to core dental services, excludes specialty services

Possible Extensions:
1. Add geographic analysis by state/region
2. Include temporal trends across years
3. Correlate copay levels with plan premiums
4. Analyze relationship between copays and utilization
5. Compare copay structures across parent organizations
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:23:34.753158
    - Additional Notes: Query focuses on member cost-sharing through copayments across different dental service categories and plan types. Excludes plans with small sample sizes (<10) to ensure statistical significance. Zero-dollar copays are treated as no copay, which may not reflect actual plan design in all cases.
    
    */