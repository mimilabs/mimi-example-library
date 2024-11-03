-- Title: Medicare Part D Coverage Gap and Premium Assistance Analysis

-- Business Purpose:
-- This analysis examines Part D drug coverage characteristics and premium assistance levels to help:
-- - Identify plans offering enhanced coverage during the "donut hole" gap
-- - Analyze accessibility for low-income beneficiaries through premium assistance tiers
-- - Support strategic planning for pharmacy benefit design and marketing
-- - Guide beneficiary outreach and education initiatives

SELECT 
    state,
    COUNT(DISTINCT contract_id || plan_id) as total_plans,
    
    -- Coverage gap analysis
    ROUND(AVG(CASE WHEN extra_coverage_in_gap = 'Yes' THEN 1.0 ELSE 0.0 END) * 100, 1) as pct_plans_with_gap_coverage,
    ROUND(AVG(part_d_drug_deductible), 2) as avg_drug_deductible,
    
    -- Premium assistance analysis
    ROUND(AVG(part_d_premium_obligation_with_full_premium_assistance), 2) as avg_premium_full_assistance,
    ROUND(AVG(part_d_premium_obligation_with_75_premium_assistance), 2) as avg_premium_75pct_assistance,
    ROUND(AVG(part_d_premium_obligation_with_50_premium_assistance), 2) as avg_premium_50pct_assistance,
    ROUND(AVG(part_d_premium_obligation_with_25_premium_assistance), 2) as avg_premium_25pct_assistance,
    
    -- Market composition
    COUNT(DISTINCT organization_name) as number_of_organizations

FROM mimi_ws_1.partcd.landscape_plan_premium_report
WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                           FROM mimi_ws_1.partcd.landscape_plan_premium_report)
GROUP BY state
HAVING total_plans >= 5  -- Focus on states with meaningful plan presence
ORDER BY total_plans DESC

-- How this works:
-- 1. Takes the most recent snapshot of plan data using latest mimi_src_file_date
-- 2. Calculates key metrics per state:
--    - Percentage of plans offering extra coverage during the gap
--    - Average drug deductible
--    - Average premium obligations across different assistance levels
--    - Market competition indicators
-- 3. Filters for states with at least 5 plans to ensure meaningful analysis
-- 4. Orders results by total plan count to highlight largest markets first

-- Assumptions and Limitations:
-- - Assumes current data snapshot represents active plans
-- - Limited to state-level analysis; county-level variations not captured
-- - Does not account for enrollment numbers or market share
-- - Focus is on Part D features rather than complete plan benefits

-- Possible Extensions:
-- 1. Add temporal analysis to track changes over multiple mimi_src_file_dates
-- 2. Include county-level detail for targeted geographic analysis
-- 3. Cross-reference with star ratings to analyze quality vs. coverage trade-offs
-- 4. Segment analysis by organization_type to compare carrier strategies
-- 5. Add specific drug tier coverage analysis using tiers_not_subject_to_deductible

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:02:47.386525
    - Additional Notes: Query focuses on two key Medicare Part D aspects: coverage gap benefits and premium assistance tiers. Consider memory usage when extending to include temporal analysis as the dataset can be large. Results are most meaningful when filtered for recent dates and active plans.
    
    */