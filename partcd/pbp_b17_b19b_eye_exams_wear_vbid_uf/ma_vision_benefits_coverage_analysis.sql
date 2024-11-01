-- Medicare Advantage Eye Exam and Eyewear Benefits Analysis
-- Purpose: Analyze the coverage and accessibility of vision benefits across Medicare Advantage plans
-- Business Value: Identify market opportunities and benefit design patterns to inform strategic decisions

/* 
This analysis provides insights into:
- Vision benefit adoption rates across plan types
- Authorization/referral requirements that may impact access
- Maximum coverage limits and cost-sharing approaches
*/

SELECT 
    pbp_a_plan_type,
    COUNT(DISTINCT bid_id) as total_plans,
    
    -- Eye Exam Coverage Analysis
    ROUND(AVG(CASE WHEN pbp_b17a_bendesc_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_eye_exams,
    ROUND(AVG(CASE WHEN pbp_b17a_auth_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_requiring_auth_exams,
    ROUND(AVG(CASE WHEN pbp_b17a_maxplan_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_max_coverage_exams,
    
    -- Eyewear Coverage Analysis
    ROUND(AVG(CASE WHEN pbp_b17b_bendesc_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_eyewear,
    ROUND(AVG(CASE WHEN pbp_b17b_maxplan_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_max_coverage_eyewear,
    
    -- Cost Sharing Approach
    ROUND(AVG(CASE WHEN pbp_b17b_copay_yn = 'Y' THEN 1 ELSE 0 END) * 100, 1) as pct_with_copay_eyewear

FROM mimi_ws_1.partcd.pbp_b17_b19b_eye_exams_wear_vbid_uf

-- Get most recent data snapshot
WHERE mimi_src_file_date = (
    SELECT MAX(mimi_src_file_date) 
    FROM mimi_ws_1.partcd.pbp_b17_b19b_eye_exams_wear_vbid_uf
)

GROUP BY pbp_a_plan_type
HAVING COUNT(DISTINCT bid_id) > 10  -- Filter out rare plan types
ORDER BY total_plans DESC;

/*
How this query works:
1. Aggregates key vision benefit metrics by plan type
2. Calculates percentage of plans offering various benefit features
3. Focuses on most recent data snapshot
4. Excludes rare plan types to ensure meaningful comparisons

Assumptions and Limitations:
- Assumes current snapshot is most representative of market
- Doesn't account for geographic variations
- Doesn't analyze actual benefit amounts/limits
- Excludes small plan types which may have unique approaches

Possible Extensions:
1. Add geographic analysis by state/region
2. Compare benefit changes over time using different snapshots
3. Add detailed cost sharing analysis (specific copay/coinsurance amounts)
4. Analyze relationship between vision benefits and plan premiums
5. Include VBID-specific analysis for targeted populations
*/

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:46:14.004655
    - Additional Notes: Query focuses on core Medicare Advantage vision benefit metrics across plan types, including coverage rates, authorization requirements, and cost-sharing approaches. Best used for market analysis and benefit design benchmarking. Results can be significantly affected by the snapshot date selected.
    
    */