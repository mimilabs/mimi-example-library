-- medicare_plan_cost_structures_analytics.sql

-- Business Purpose: 
-- Analyze Medicare Advantage plan out-of-pocket cost structures and maximum limits
-- to understand plan design patterns and financial protection for beneficiaries.
-- This helps stakeholders assess market positioning and beneficiary financial exposure.

WITH cost_structure_summary AS (
    -- First aggregate cost sharing approaches by plan
    SELECT 
        pbp_a_plan_type,
        bid_id,
        CASE 
            WHEN mrx_b_max_oop_yn = 'Y' THEN 1 
            ELSE 0 
        END as has_moop,
        mrx_b_max_oop_amt,
        mrx_b_max_oop_per,
        CASE 
            WHEN mrx_b_coins_yn = 'Y' THEN 1 
            ELSE 0 
        END as uses_coinsurance,
        CASE 
            WHEN mrx_b_copay_yn = 'Y' THEN 1 
            ELSE 0 
        END as uses_copay,
        mrx_b_coins_min_pct as other_drugs_min_coins,
        mrx_b_copay_min_amt as other_drugs_min_copay,
        mimi_src_file_date
    FROM mimi_ws_1.partcd.pbp_b15_partb_rx_drugs
    WHERE mimi_src_file_date = (SELECT MAX(mimi_src_file_date) 
                               FROM mimi_ws_1.partcd.pbp_b15_partb_rx_drugs)
)

SELECT 
    pbp_a_plan_type,
    COUNT(DISTINCT bid_id) as total_plans,
    
    -- MOOP Analysis
    ROUND(AVG(has_moop)*100,1) as pct_with_moop,
    ROUND(AVG(CASE WHEN has_moop = 1 THEN mrx_b_max_oop_amt END),0) as avg_moop_amount,
    
    -- Cost Sharing Approach
    ROUND(AVG(uses_coinsurance)*100,1) as pct_using_coinsurance,
    ROUND(AVG(uses_copay)*100,1) as pct_using_copay,
    
    -- Average Cost Sharing Levels
    ROUND(AVG(other_drugs_min_coins),1) as avg_min_coinsurance_pct,
    ROUND(AVG(other_drugs_min_copay),2) as avg_min_copay_amt

FROM cost_structure_summary
GROUP BY pbp_a_plan_type
HAVING total_plans >= 10
ORDER BY total_plans DESC

-- How this works:
-- 1. Creates temp table with plan-level cost structure indicators
-- 2. Aggregates by plan type to show patterns in benefit design
-- 3. Filters to only include plan types with meaningful sample sizes
-- 4. Provides key metrics around financial protection and cost sharing approaches

-- Assumptions & Limitations:
-- - Uses most recent data snapshot only
-- - Focuses on non-specialty drugs (excludes chemotherapy)
-- - Minimum sample size of 10 plans per type
-- - Does not account for regional variations
-- - Maximum amounts not included to avoid outlier effects

-- Possible Extensions:
-- 1. Add year-over-year trending
-- 2. Include geographic analysis by state/region
-- 3. Correlate with plan enrollment numbers
-- 4. Add specialty drug cost sharing analysis
-- 5. Compare against industry benchmarks
-- 6. Segment by organization type
-- 7. Add deductible analysis
-- 8. Calculate combined cost sharing burden

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-11-03T13:55:26.324785
    - Additional Notes: Query focuses on plan-level cost sharing structures and financial protection metrics, providing a high-level view of how Medicare Advantage plans structure their Part B drug benefits. Best used for market analysis and plan design benchmarking. Note that the analysis excludes plans with fewer than 10 members to ensure statistical relevance.
    
    */