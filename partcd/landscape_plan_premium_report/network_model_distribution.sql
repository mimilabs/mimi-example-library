-- Title: Medicare Advantage Plan Network Configuration Analysis

-- Business Purpose:
-- This analysis examines the distribution and characteristics of different plan types (HMO, PPO, etc.)
-- to help healthcare organizations:
-- - Understand network design patterns across different regions
-- - Assess market penetration opportunities based on plan type prevalence
-- - Identify potential gaps in network coverage models
-- - Guide strategic decisions about plan type offerings

SELECT 
    state,
    plan_type,
    -- Count distinct plans to understand market composition
    COUNT(DISTINCT CONCAT(contract_id, plan_id)) as number_of_plans,
    -- Calculate average premiums by plan type
    ROUND(AVG(COALESCE(part_c_premium, 0) + COALESCE(part_d_total_premium, 0)), 2) as avg_total_premium,
    -- Get median star rating to assess quality
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY overall_star_rating) as median_star_rating,
    -- Calculate percent of plans offering drug coverage
    ROUND(100.0 * COUNT(CASE WHEN benefit_type = 'MA-PD' THEN 1 END) / COUNT(*), 2) as pct_with_drug_coverage,
    -- Count organizations to assess market concentration
    COUNT(DISTINCT organization_name) as number_of_organizations
FROM mimi_ws_1.partcd.landscape_plan_premium_report
WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                           FROM mimi_ws_1.partcd.landscape_plan_premium_report)
GROUP BY state, plan_type
HAVING number_of_plans >= 5  -- Focus on meaningful market presence
ORDER BY state, number_of_plans DESC;

-- How it works:
-- 1. Selects the most recent data using the latest mimi_src_file_date
-- 2. Groups plans by state and plan type to show network model distribution
-- 3. Calculates key metrics including plan counts, average premiums, and quality measures
-- 4. Filters for states with significant market presence (5+ plans)

-- Assumptions and Limitations:
-- - Assumes current data patterns reflect stable market conditions
-- - Limited to states with sufficient plan presence for meaningful analysis
-- - Does not account for geographical variations within states
-- - Premium calculations may not reflect all cost considerations

-- Possible Extensions:
-- 1. Add year-over-year trend analysis to track network evolution
-- 2. Include county-level analysis for more granular insights
-- 3. Add market share analysis based on organization concentration
-- 4. Incorporate special needs plan distribution by network type
-- 5. Compare rural vs urban network configurations
-- 6. Analyze relationship between network type and star ratings
-- 7. Examine premium variations within network types

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-05T23:07:52.510877
    - Additional Notes: Query focuses on network configuration patterns across states, with emphasis on market maturity (5+ plans threshold). Premium calculations include both Part C and Part D components, which may not fully represent total beneficiary costs. The analysis is point-in-time based on latest data snapshot and doesn't reflect historical network evolution.
    
    */