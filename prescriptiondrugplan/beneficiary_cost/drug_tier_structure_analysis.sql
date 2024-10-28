
-- tier_coverage_analysis.sql
/********************************************************************************
Business Purpose: 
Analyze prescription drug plan tier coverage and cost sharing structures to help:
- Understand how plans design their drug tiers
- Identify which tiers have deductible coverage and gap coverage
- Compare cost sharing approaches across tiers

Key business value:
- Assists in plan design optimization
- Supports beneficiary education about tier structures
- Enables cost management strategy development
********************************************************************************/

WITH tier_summary AS (
  SELECT 
    tier,
    -- Calculate tier usage statistics
    COUNT(DISTINCT CONCAT(contract_id, plan_id, segment_id)) as total_plans,
    
    -- Analyze deductible coverage
    ROUND(AVG(CASE WHEN ded_applies_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_deductible,
    
    -- Analyze gap coverage 
    ROUND(SUM(CASE WHEN gap_cov_tier = '1' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) as pct_fully_covered_in_gap,
    ROUND(SUM(CASE WHEN gap_cov_tier = '2' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) as pct_partially_covered_in_gap,
    
    -- Analyze cost sharing approaches
    ROUND(SUM(CASE WHEN cost_type_pref = '1' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) as pct_using_copay,
    ROUND(SUM(CASE WHEN cost_type_pref = '2' THEN 1 ELSE 0 END) / COUNT(*) * 100, 1) as pct_using_coinsurance,
    
    -- Calculate average preferred pharmacy cost amount
    ROUND(AVG(CASE WHEN cost_type_pref = '1' THEN cost_amt_pref END), 2) as avg_copay_amt,
    ROUND(AVG(CASE WHEN cost_type_pref = '2' THEN cost_amt_pref END) * 100, 1) as avg_coinsurance_pct,
    
    -- Identify specialty tier designation
    ROUND(AVG(CASE WHEN tier_specialty_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_specialty_tier
    
  FROM mimi_ws_1.prescriptiondrugplan.beneficiary_cost
  WHERE coverage_level = '1' -- Focus on initial coverage period
    AND days_supply = '1'   -- Focus on 30-day supply
  GROUP BY tier
  ORDER BY tier
)

SELECT *
FROM tier_summary;

/*
How this query works:
1. Filters to initial coverage period and 30-day supply for consistent comparison
2. Groups data by tier to analyze tier-level patterns
3. Calculates various statistics about coverage and cost sharing approaches
4. Presents results in an easy-to-analyze format

Assumptions and Limitations:
- Focuses only on initial coverage period
- Analyzes 30-day supply costs only
- Does not account for regional variations
- Assumes tier numbering is consistent across plans

Possible Extensions:
1. Add temporal analysis to show how tier structures change over time
2. Include geographic comparisons by joining with plan_information
3. Compare tier structures between MA-PD and PDP plans
4. Add analysis of mail order vs retail pharmacy differences
5. Expand to include coverage gap and catastrophic coverage periods
*/
/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-28T14:24:52.134202
    - Additional Notes: Query focuses on plan design characteristics and cost sharing patterns at the tier level. This base analysis can be particularly useful for insurers designing new plans or researchers studying market trends. Note that results are most meaningful when analyzed alongside plan enrollment data and actual utilization patterns.
    
    */