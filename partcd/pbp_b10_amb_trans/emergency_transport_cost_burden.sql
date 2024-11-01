-- Emergency Transportation Cost Analysis for Medicare Advantage Plans
--
-- Business Purpose:
-- Analyzes emergency transportation cost-sharing structures across Medicare Advantage plans
-- to identify financial burdens on beneficiaries and potential access barriers.
-- This information is valuable for:
-- 1. Plan administrators evaluating market competitiveness
-- 2. Policy makers assessing beneficiary out-of-pocket exposure
-- 3. Healthcare systems understanding patient transportation costs
--

WITH plan_costs AS (
    -- Get core cost sharing information for emergency ground transport
    SELECT 
        pbp_a_plan_type,
        COUNT(DISTINCT bid_id) as total_plans,
        
        -- Analyze copay structures
        AVG(CASE WHEN pbp_b10a_copay_yn = 'Y' THEN 1 ELSE 0 END) * 100 as pct_with_copay,
        AVG(pbp_b10a_copay_gas_amt_max) as avg_max_ground_copay,
        
        -- Analyze coinsurance structures
        AVG(CASE WHEN pbp_b10a_coins_yn = 'Y' THEN 1 ELSE 0 END) * 100 as pct_with_coinsurance,
        AVG(pbp_b10a_coins_gas_pct_max) as avg_max_ground_coinsurance,
        
        -- Analyze hospital admission waivers
        AVG(CASE WHEN pbp_b10a_copay_wav_yn = 'Y' THEN 1 ELSE 0 END) * 100 as pct_waived_if_admitted
        
    FROM mimi_ws_1.partcd.pbp_b10_amb_trans
    WHERE pbp_a_plan_type IS NOT NULL
    GROUP BY pbp_a_plan_type
)

SELECT 
    pbp_a_plan_type as plan_type,
    total_plans,
    ROUND(pct_with_copay, 1) as pct_plans_with_copay,
    ROUND(avg_max_ground_copay, 2) as avg_max_copay_amt,
    ROUND(pct_with_coinsurance, 1) as pct_plans_with_coinsurance,
    ROUND(avg_max_ground_coinsurance, 1) as avg_max_coinsurance_pct,
    ROUND(pct_waived_if_admitted, 1) as pct_waive_on_admission
FROM plan_costs
WHERE total_plans >= 10  -- Filter for meaningful sample sizes
ORDER BY total_plans DESC;

-- How this query works:
-- 1. Creates a CTE to aggregate key cost metrics by plan type
-- 2. Calculates percentages of plans with different cost sharing approaches
-- 3. Computes average maximum costs for copays and coinsurance
-- 4. Analyzes hospital admission waiver policies
-- 5. Presents results filtered for plan types with sufficient sample size

-- Assumptions and Limitations:
-- - Focuses only on ground ambulance services
-- - Assumes max copay/coinsurance values are representative
-- - Does not account for regional variations
-- - Limited to current snapshot without historical trends

-- Possible Extensions:
-- 1. Add geographic analysis by state/region
-- 2. Compare air vs ground ambulance cost sharing
-- 3. Trend analysis across multiple years
-- 4. Correlation with plan premiums or star ratings
-- 5. Analysis of prior authorization requirements
-- 6. Integration with utilization or claims data

/*

    - Author: claude-3-5-sonnet-20241022
    - Created At: 2024-10-31T18:11:16.091739
    - Additional Notes: Query focuses on financial exposure metrics for emergency ground transportation across plan types. Results are most meaningful when analyzed alongside plan enrollment numbers and regional cost-of-living data. Consider supplementing with Medicare FFS comparison data for fuller market context.
    
    */